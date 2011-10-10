package DjakaWeb::Controllers;

use Dancer;
use Dancer::Plugin::DBIC;
use DjakaWeb::Elements::Game;

sub login_stub
{
	my $user_id = shift;
	my $game_id = schema->resultset('Game')->get_active_game($user_id);
	my $game;
	if(! $game_id)
	{
		$game = DjakaWeb::Elements::Game->new({'user' => $user_id, 'mission' => '000'});
		session 'game' => $game;
		return 0; #new game
	}
	else
	{
		$game = DjakaWeb::Elements::Game->new({'id' => $game_id});
		session 'game' => $game;
		return 1; #existing game	
		#return redirect '/game';
	}

}

sub get_data_for_interface
{
	my $game = session('game');
	my %elements = $game->getElements();
	my $story = $game->getAllStory();
	#print keys %{$elements{'person'}[0]};
	return {'game_id' => $game->id(),
		    'user_id' => $game->user(),
		 	'elements' => \%elements,
			'story' => $story,
			'danger' => $game->danger()};
}

sub get_actions_menu
{
	my $element = shift;
	my $game = session('game');
	my %actions = $game->getActions($element);
	my @labels = keys %actions;
	return {'actions' => \@labels, 
			'layout'  => 0};
}




1;
