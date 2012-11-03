package DjakaWeb::Controllers;

use JSON 'decode_json';
use LWP::UserAgent;
use MIME::Base64 'decode_base64url', 'encode_base64url';
use Digest::SHA 'hmac_sha256';
use Data::Dumper;
use Dancer ':syntax';
use DjakaWeb;
use DjakaWeb::Elements::Game;
use DjakaWeb::Elements::User;

use constant GAME_LOST => -1000;
use constant ACTION_ERROR => -101;
use constant CLICK_ERROR => -100;
use constant CLICK_DONE => 100;
use constant ACTION_DONE => 101;
use constant GAME_WON => 1000;

sub facebook_data
{
    my $val;
	my $app_id = config->{facebook}->{'app_id'};
	if(config->{facebook}->{stubbed} == 1)
	{
        $val = config->{facebook}->{stubbed_cookie};
	}
	else
	{
		my $cookie = cookies->{'fbsr_' . $app_id};
		if(! $cookie)
		{
			return 0;
		}
		$val = $cookie->value;
	}
	my ($encoded_sig, $payload) = split('\.', $val);
	my $decoded_payload = decode_base64url($payload);
	my $json = decode_json($decoded_payload);
	if(uc($json->{'algorithm'}) !~ /HMAC-SHA256/)
	{
		return {'error' => 'Unknown algorithm. Expected HMAC-SHA256'};
	}
	my $check_sig = hmac_sha256($payload, config->{facebook}->{secret});
	if(encode_base64url($check_sig) ne $encoded_sig)
	{
		debug "LOGIN: Bad facebook cookie: $check_sig <---> $encoded_sig";
		return 0;
	}
	my $facebook_id = $json->{'user_id'};
    if(config->{facebook}->{stubbed} == 1 && config->{facebook}->{fake_id})
    {
        $facebook_id = config->{facebook}->{fake_id};
    }

	my $user = DjakaWeb::Elements::User->new({'facebook_id' => $facebook_id});
	session 'user' => $user->id();
	my $game_id = DjakaWeb::Elements::Game::get_active_game($user->id());
	if(! $game_id)
	{
		#At this time, when no game exists, a new one with mission 000 is created
		my $game = DjakaWeb::Elements::Game->new({'user' => $user->id(), 'mission' => '000', 'stories_path' => config->{'stories_path'}});
		session 'game' => $game->id();
	}
	else
	{
		my $game = DjakaWeb::Elements::Game->new({'id' => $game_id, 'stories_path' => config->{'stories_path'}});
		session 'game' => $game->id();
	}
	return 1;
}

sub facebook_user
{
	my $facebook_id = shift;
	my $ua = new LWP::UserAgent;
	$ua->agent("Mozilla/5.0 " . $ua->agent);
	my $req = new HTTP::Request GET => config->{'facebook'}->{'graph_url'} . $facebook_id;
	my $res = $ua->request($req);
	my $content, my $fbjson;
	if ($res->is_success) 
	{
	 	$content = $res->content;
		$fbjson = decode_json($content);
		return $fbjson;
	} 
	else
	{
		return undef;
	}
}

sub get_data_for_interface
{
	my ($user, $game) = build_elements();
	my %elements = $game->get_elements();
	my $story = $game->get_all_story();
	my $active_A = $game->get_active_action();
	my $ttc = $user->time_to_click(config->{'wait_to_click'});
	my $last_action_class = session('action');
	session 'action' => undef;
	#my $name = session('user_name') ? session('user_name') : $user->id();
	#print keys %{$elements{'person'}[0]};
	return {'app_domain' => config->{'app_domain'},
			'game_id' => $game->id(),
		    'user_id' => $user->id(),
			'fb_app_id' => config->{'facebook'}->{'app_id'},
			'graph_domain' => config->{'facebook'}->{'graph_domain'},
			'last_action_done' => $user->last_action_done(),
			'time_to_click' => $ttc,
			'allowed_click' => ($ttc <= 0) ,
		 	'elements' => \%elements,
			'story' => $story,
			'danger' => $game->danger(),
			'action' => $active_A,
			'last_action_class' => $last_action_class
		};
}
sub get_data_for_badge
{
	my ($user, $game) = build_elements();
	my $user_data = facebook_user($user->facebook_id());
	return {'username' => $user_data->{'name'},
			'avatar' => config->{'facebook'}->{'graph_url'} . $user->facebook_id() . '/picture',
	};

}

sub get_data_for_help
{
	my $action = shift;
	my ($user, $game) = build_elements(); #This game is not directly involved, can be null
	my $ttc;
	if($user)
	{
 		$ttc = $user->time_to_support_click(config->{'wait_to_support_click'});
	}
	else
	{
		$ttc = -1;
	}
	my ($game_to_help, $ongoing_action) = DjakaWeb::Elements::Game::get_game_from_ongoing($action, config->{'stories_path'});
	if($ongoing_action)
	{
		my $user_to_help = DjakaWeb::Elements::User->new({'id' => $game_to_help->user});
		my $user_to_help_data = facebook_user($user_to_help->facebook_id());
		my $errors = 'NONE';
		if($ongoing_action->active == 0)
		{
			$errors = 'INACTIVE_ACTION';
		}
		if($user && $user->id == $user_to_help->id)
		{
			$errors = 'SAME_USER';
		}
		return {'app_domain' => config->{'app_domain'},
				'graph_domain' => config->{'facebook'}->{'graph_domain'},
			    'app_call' => '/share/help/' . $ongoing_action->id,
				'userid_to_help' => $user_to_help->facebook_id(),
				'username_to_help' => $user_to_help_data->{'name'},
				'action' => $game_to_help->get_action_data($ongoing_action),
				'errors' => $errors,
				'time_to_click' => $ttc,
				'allowed_click' => ($ttc <= 0) ,
		 		'fb_app_id' => config->{'facebook'}->{'app_id'},
				};
	}
	else
	{
		return {'errors' => 'BAD_ACTION'};
	}

}

sub get_actions_menu
{
	my $element = shift;
	my ($user, $game) = build_elements();
	my %actions = $game->get_actions($element);
	my @labels = keys %actions;
	return {'actions' => \@labels, 
			'layout'  => 0,
			'element' => $element,
			'element_name' => $game->get_element_name($element)};
}

sub get_element_description
{
	my $element = shift;
	my ($user, $game) = build_elements();
	return {'description' => $game->get_element_description($element)};
}

sub schedule_action
{
	my ($user, $game) = build_elements();
	my $element = shift;
	my $action = shift;
	my $A = $game->get_active_action();
    #print Dumper($A);
	if($A->{'action'} =~ m/^NONE$/)
	{
		$game->schedule_action($element, $action);
		return click();
	}
	else
	{
		return ACTION_ERROR;
	}
}

sub click
{
	my ($user, $game) = build_elements();
	if($game->get_active_action()->{'id'} == -1)
	{
		return CLICK_ERROR;
	}
	if($user->time_to_click(config->{'wait_to_click'}) <= 0)
	{
		$user->update_click_time();
		$user->trace_click($game->get_active_action()->{'id'}, 'ACTIVE');
		my $click_result = $game->click(config->{'clicks'});
		if($click_result == 1)
		{
			if($game->danger > config->{'danger_threshold'})
			{
				session 'end' => '__GAMEOVER__';
				return GAME_LOST; 
			}
			else
			{
				if(my $tag = $game->check_victory())
				{
					session 'end' => $tag;
					return GAME_WON;
				}
				else
				{
					session 'action' => 'done';
					return ACTION_DONE;
				}
			}
		}
		elsif($click_result == -1)
		{
			return CLICK_ERROR;
		}
		else
		{
			return CLICK_DONE;
		}
	}
	else
	{
		return CLICK_ERROR;
	}
}
sub support_click
{
	my $action = shift;
	my ($user, $game) = build_elements();
	my ($game_to_help, $ongoing_action) = DjakaWeb::Elements::Game::get_game_from_ongoing($action, config->{'stories_path'});
	if($user->time_to_support_click(config->{'wait_to_support_click'}) <= 0)
	{
		$user->update_support_click_time();
		$user->trace_click($action, 'SUPPORT');
		my $click_result = $game_to_help->click(config->{'clicks'});
		if($click_result == -1)
		{
			return CLICK_ERROR;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return CLICK_ERROR;
	}
}


sub build_elements
{
	my ($user, $game);
	if(session('game'))
	{
		$game = DjakaWeb::Elements::Game->new({'id' => session('game'), 'stories_path' => config->{'stories_path'}});
	}
	else
	{
		$game = undef;
	}
	if(session('user'))
	{
		$user = DjakaWeb::Elements::User->new({'id' => session('user')});
	}
	else
	{
		$user = undef;
	}
	return ($user, $game);
}



1;
