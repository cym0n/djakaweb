package DjakaWeb::Controllers;

use JSON;
use MIME::Base64 'decode_base64url', 'encode_base64url';
use Digest::SHA 'hmac_sha256';
use Data::Dumper;
use Dancer;
use DjakaWeb::Elements::Game;
use DjakaWeb::Elements::User;

sub login_stub
{
	my $user_id = shift;
	my $user = DjakaWeb::Elements::User->new({'id' => $user_id, 'stories_path' => config->{'stories_path'}});
	session 'user' => $user->id();
	my $game_id = DjakaWeb::Elements::Game::get_active_game($user->id());
	my $game;
	if(! $game_id)
	{
		#At this time, when no game exists, a new one with mission 000 is created
		$game = DjakaWeb::Elements::Game->new({'user' => $user->id(), 'mission' => '000', 'stories_path' => config->{'stories_path'}});
		session 'game' => $game->id();
		return 0; #new game
	}
	else
	{
		$game = DjakaWeb::Elements::Game->new({'id' => $game_id, 'stories_path' => config->{'stories_path'}});
		session 'game' => $game->id();
		return 1; #existing game	
		#return redirect '/game';
	}

}

sub facebook_data
{
	my $app_id = config->{facebook}->{'app_id'};
	my $val;
	if(config->{facebook}->{stubbed})
	{
		$val = "WhTeWdR-c4SHRCsW1IN3cfcmm1Tsv_-Gijf_OfN3OXk.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImNvZGUiOiJBUUM0YlhXNUJVUElXTFZqN095TEtsMkpSNDRpRk9aaXVac3pRcU5UQy1oTzM4Wmp1UFZJX0NfUnNpOFZpOFdqZ0k5b0EtcTNaWkVMbG1hbXBOZS1ac01CRDJhLXY0eXBQREZJS0R2MnBiX3F5blc5akVvaG9pWEZhN0ZqZGRsWjVlY0lPRHRlcURqTmUtWDhORlNGVG1PM0dQWnluNVVjSEI5RzBHR3FCMUotM1pIa2Myd1k2b3YzQW5jenV5ejItVVEiLCJpc3N1ZWRfYXQiOjEzMzExNTkwMTEsInVzZXJfaWQiOiIxNDUyMzk0Nzg2In0";	
	}
	else
	{
		my $cookie = cookies->{'fbsr_' . $app_id};
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
	return {#'cookie_value' => $cookie->value,
			'cookie_value' => $val,
			'check_value' => encode_base64url($check_sig),
	        'fbuser_id' => $json->{'user_id'}};
}

sub get_data_for_interface
{
	my ($user, $game) = build_elements();
	my %elements = $game->get_elements();
	my $story = $game->get_all_story();
	my $active_A = $game->get_active_action();
	my $ttc = $user->time_to_click(config->{'wait_to_click'});
	my $user_displayed;
	if(session->{access_token})
	{
		my $fb = Facebook::Graph->new( config->{facebook} );
    	$fb->access_token(session->{access_token});
	    my $response = $fb->query->find('me')->request;
    	my $fb_user = $response->as_hashref;
		$user_displayed = $fb_user->name();
	}
	else
	{
		$user_displayed = $user->id();
	}
	#print keys %{$elements{'person'}[0]};
	return {'game_id' => $game->id(),
		    'user_id' => $user_displayed,
			'last_action_done' => $user->last_action_done(),
			'time_to_click' => $ttc,
			'allowed_click' => ($ttc <= 0) ,
		 	'elements' => \%elements,
			'story' => $story,
			'danger' => $game->danger(),
			'action' => $active_A
		};
}

sub get_actions_menu
{
	my $element = shift;
	my ($user, $game) = build_elements();
	my %actions = $game->get_actions($element);
	my @labels = keys %actions;
	return {'actions' => \@labels, 
			'layout'  => 0,
			'element' => $element};
}

sub schedule_action
{
	my ($user, $game) = build_elements();
	my $element = shift;
	my $action = shift;
	my $A = $game->get_active_action();
	if($A->{'action'} =~ m/^NONE$/)
	{
		$game->schedule_action($element, $action);
	}
}

sub click
{
	my ($user, $game) = build_elements();
	if($user->time_to_click(config->{'wait_to_click'}) <= 0)
	{
		$user->update_click_time();
		if($game->click(config->{'clicks'}))
		{
			if($game->danger > config->{'danger_threshold'})
			{
				session 'end' => 'GAMEOVER';
			}
			else
			{
				if(my $tag = $game->check_victory())
				{
					session 'end' => $tag;
				}
			}
		}
	}
	else
	{
	}
}

sub build_elements
{
	my $game = DjakaWeb::Elements::Game->new({'id' => session('game'), 'stories_path' => config->{'stories_path'}});
	my $user = DjakaWeb::Elements::User->new({'id' => session('user')});
	return ($user, $game);
}



1;
