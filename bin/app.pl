#!/usr/bin/env perl
use Dancer;
use Dancer::Plugin::DBIC;
use Dancer::Template::TemplateToolkit;
use DjakaWeb;
use DjakaWeb::Elements::Game;

 set layout => 'djaka';

get '/home' => sub {
	my $user = schema->resultset('Game')->find('1');
	return $user->mission_id();

};

get '/login/:id' => sub {
    my $id = params->{id};
	my $game_id = schema->resultset('Game')->get_active_game($id);
	my $game;
	if(! $game_id)
	{
		$game = DjakaWeb::Elements::Game->new({'user' => $id, 'mission' => '000'});
		return redirect '/newgame/' . $game->id();
	}
	else
	{
		$game = DjakaWeb::Elements::Game->new({'id' => $game_id});
		return redirect '/game/' . $game->id();
	}
};

get '/game/:game' => sub {
	template 'interface';



};





dance;
