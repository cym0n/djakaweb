#!/usr/bin/env perl
use lib "perl/lib/perl5";
use Dancer;
use Dancer::Plugin::DBIC;
use Dancer::Template::TemplateToolkit;
use DjakaWeb;
use DjakaWeb::Elements::Game;
use DjakaWeb::Controllers;

before sub {
	if(request->path_info !~ /courtesy/ && request->path_info !~ /login/)
	{
		if(! session('game'))
		{
			request->path_info('/courtesy/not_logged');
    	};
	}
	if(request->path_info !~ /win/ && request->path_info !~ /gameover/)
	{
		if(session('end'))
		{
			if(session('end') =~ /GAMEOVER/)
			{
				redirect '/gameover';
			}
			else
			{
				if(session('end'))
				{
					redirect '/win';
				}
			}
		}
	}
};

get '/login/:id?' => sub {
	my $login = DjakaWeb::Controllers::login_stub(params->{id});
	if($login == 0)
	{
		return redirect '/game';
	}
	elsif($login == 1)
	{
		return redirect '/game';
	}
	elsif($login == -1)
	{
		return redirect '/courtesy/login_failed';
	}
};

get '/game' => sub {
	template 'interface' => DjakaWeb::Controllers::get_data_for_interface(), {'layout' => 'interface.tt'};
};

get '/do/:action/:element' => sub {
	DjakaWeb::Controllers::schedule_action(params->{element}, params->{action});
	return redirect '/game';
};

get '/click' => sub {
	DjakaWeb::Controllers::click();
	redirect '/game';
};

get '/gameover' => sub {
	if(session('end') =~ /GAMEOVER/)
	{
		template 'gameover';
	}
	else
	{
		redirect '/game';
	}
};
get '/win' => sub {
	if(session('end'))
	{
		template 'win' => { 'tag' => session('end')};
	}
	else
	{
		redirect '/game';
	}
};


#AJAX CALLS
get '/service/actions/:id' => sub {
	template 'actions' => DjakaWeb::Controllers::get_actions_menu(params->{id});
};


#COURTESY PAGES
get '/courtesy/not_logged' => sub {
	template 'not_logged';
};
get '/courtesy/login_failed' => sub {
	template 'login_failed';
};




dance;
