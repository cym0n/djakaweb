#!/usr/bin/env perl
use Dancer;
use Dancer::Plugin::DBIC;
use Dancer::Template::TemplateToolkit;
use DjakaWeb;
use DjakaWeb::Elements::Game;
use DjakaWeb::Controllers;

set layout => 'djaka';

before sub {
	if(request->path_info !~ /courtesy/ && request->path_info !~ /login/)
	{
		if(! session('game'))
		{
			 request->path_info('/courtesy/not_logged');
    	};
	}
};

get '/login/:id' => sub {
	if(DjakaWeb::Controllers::login_stub(params->{id}))
	{
		return redirect '/game';
	}
	else
	{
		return redirect '/game';
	}
};



get '/game' => sub {
	template 'interface' => DjakaWeb::Controllers::get_data_for_interface();
};

get '/do/:action/:element' => sub {
	my $game = session('game');
	$game->do(params->{element}, params->{action}, 'human');
	return redirect '/game';
};





#AJAX CALLS
get '/service/actions/:id' => sub {
	template 'actions' => DjakaWeb::Controllers::get_actions_menu(params->{id});
};





#COURTESY PAGES
get '/courtesy/not_logged' => sub {
	template 'not_logged';
};




dance;
