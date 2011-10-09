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

get '/courtesy/not_logged' => sub {
	template 'not_logged';
};

get '/game' => sub {
	template 'interface' => DjakaWeb::Controllers::get_data_for_interface();
};

dance;
