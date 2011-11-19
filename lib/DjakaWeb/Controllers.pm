package DjakaWeb::Controllers;

use Dancer;
use Dancer::Plugin::DBIC;
use DjakaWeb::Elements::Game;

sub login_stub
{
	my $user_id = shift;
	my $user;
	if(! $user_id)
	{
	 	$user = schema->resultset('User')->newUser();
	}
	else
	{
		$user = schema->resultset('User')->find($user_id);
	}
	if(! $user)
	{
		return -1; #login failed
	}
	session 'user' => $user;
	my $game_id = schema->resultset('Game')->get_active_game($user->id());
	my $game;
	if(! $game_id)
	{
		#At this time, when no game exists, a new one with mission 000 is created
		$game = DjakaWeb::Elements::Game->new({'user' => $user->id(), 'mission' => '000', 'schema' => schema});
		session 'game' => $game;
		return 0; #new game
	}
	else
	{
		$game = DjakaWeb::Elements::Game->new({'id' => $game_id, 'schema' => schema});
		session 'game' => $game;
		return 1; #existing game	
		#return redirect '/game';
	}

}

sub get_data_for_interface
{
	my $game = session('game');
	my $user = session('user');
	my %elements = $game->get_elements();
	my $story = $game->get_all_story();
	#print keys %{$elements{'person'}[0]};
	return {'game_id' => $game->id(),
		    'user_id' => $user->id(),
		 	'elements' => \%elements,
			'story' => $story,
			'danger' => $game->danger()};
}

sub get_actions_menu
{
	my $element = shift;
	my $game = session('game');
	my %actions = $game->get_actions($element);
	my @labels = keys %actions;
	return {'actions' => \@labels, 
			'layout'  => 0,
			'element' => $element};
}

sub schedule_action
{
	my $game = session('game');
	my $element = shift;
	my $action = shift;
	$game->schedule_action($element, $action);
}

sub play
{
	my $game = session('game');
	my $element = shift;
	my $action = shift;
	$game->do($element, $action, 'human');
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



1;
