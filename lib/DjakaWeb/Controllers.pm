package DjakaWeb::Controllers;

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

sub get_data_for_interface
{
	my ($user, $game) = build_elements();
	my %elements = $game->get_elements();
	my $story = $game->get_all_story();
	my $active_A = $game->get_active_action();
	my $ttc = $user->time_to_click(config->{'wait_to_click'});
	#print keys %{$elements{'person'}[0]};
	return {'game_id' => $game->id(),
		    'user_id' => $user->id(),
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
	$game->schedule_action($element, $action);
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
