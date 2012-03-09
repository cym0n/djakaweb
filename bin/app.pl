#!/usr/bin/env perl

use Dancer;
use Dancer::Template::TemplateToolkit;
use DjakaWeb;
use DjakaWeb::Controllers;

hook 'before' => sub {
	#game navigations are only for logged users
	if(request->path_info =~ !^/game!)
	{
		if(! session('user'))
		{

		}
	}
	#End of game management
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

hook 'before_template_render' => sub {
	my $tokens = shift;
	$tokens->{env} = config->{environment};
};

#get '/login/:id?' => sub {
#	my $login = DjakaWeb::Controllers::login_stub(params->{id});
#	if($login == 0)
#	{
#		return redirect '/game';
#	}
#	elsif($login == 1)
#	{
#		return redirect '/game';
#	}
#	elsif($login == -1)
#	{
#		return redirect '/courtesy/login_failed';
#	}
#};

get '/facebook/login' => sub {
	template 'facebook_access' => { 'fb_app_id' => config->{facebook}->{'app_id'}};
};
get '/facebook/welcome' => sub {
	template 'facebook_display' => DjakaWeb::Controllers::facebook_data();
};



get '/game/dashboard' => sub {
	template 'interface' => DjakaWeb::Controllers::get_data_for_interface(), {'layout' => 'interface.tt'};
};

get '/game/do/:action/:element' => sub {
	DjakaWeb::Controllers::schedule_action(params->{element}, params->{action});
	return redirect '/game';
};

get '/game/click' => sub {
	DjakaWeb::Controllers::click();
	redirect '/game';
};

get '/game/gameover' => sub {
	if(session('end') =~ /GAMEOVER/)
	{
		template 'gameover';
	}
	else
	{
		redirect '/game';
	}
};
get '/game/win' => sub {
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
get '/game/service/actions/:id' => sub {
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
