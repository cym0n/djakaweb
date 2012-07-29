#!/usr/bin/env perl

use Dancer;
use Dancer::Template::TemplateToolkit;
use DjakaWeb;
use DjakaWeb::Controllers;

hook 'before' => sub {
	#game navigations are only for logged users
	if(request->path_info =~ /^\/game/)
	{
		if(! session('user'))
		{
			my $fblogin = DjakaWeb::Controllers::facebook_data;
			if($fblogin == 0)
			{
				redirect '/facebook/login?returl=' . request->path_info;
			}

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

get '/' => sub {
	redirect '/game/dashboard';
};



get '/debugger' => sub {
	debug "DEBUGGER";
	my $dummy = 1;
	$dummy = $dummy / 0;
};

get '/facebook/login' => sub {
	template 'facebook_access' => { 'fb_app_id' => config->{facebook}->{'app_id'},
	                                'returl' => request->{params}->{returl}};
};
get '/facebook/welcome' => sub {
	template 'facebook_display' => DjakaWeb::Controllers::facebook_data();
};



get '/game/dashboard' => sub {
	template 'interface' => DjakaWeb::Controllers::get_data_for_interface(), {'layout' => 'interface.tt'};
};

get '/game/help/:action_id' => sub {
	my $data = DjakaWeb::Controllers::get_data_for_help(params->{action_id});
	if($data->{'errors'} eq 'BAD_ACTION')
	{
		return Dancer::Response->new(
        	status => 404,
        	content => 'Bad action id'
    	);
	}	
	if($data->{'errors'} eq 'SAME_USER')
	{
		redirect '/game/dashboard';
	}
	template 'help' => $data, {'layout' => 'help' };
};

get '/game/do/:action/:element' => sub {
	DjakaWeb::Controllers::schedule_action(params->{element}, params->{action});
	return redirect '/game/dashboard';
};

get '/game/click' => sub {
	DjakaWeb::Controllers::click();
	redirect '/game/dashboard';
};

get '/game/gameover' => sub {
	if(session('end') =~ /GAMEOVER/)
	{
		template 'gameover';
	}
	else
	{
		redirect '/game/dashboard';
	}
};
get '/game/win' => sub {
	if(session('end'))
	{
		template 'win' => { 'tag' => session('end')};
	}
	else
	{
		redirect '/game/dashboard';
	}
};


#AJAX CALLS
get '/game/service/actions/:id' => sub {
	template 'actions' => DjakaWeb::Controllers::get_actions_menu(params->{id}), {'layout' => 'none.tt'};
};

get '/game/service/description/:id' => sub {
	template 'description' => DjakaWeb::Controllers::get_element_description(params->{id}), {'layout' => 'none.tt'};
};


#COURTESY PAGES
get '/courtesy/not_logged' => sub {
	template 'not_logged';
};
get '/courtesy/login_failed' => sub {
	template 'login_failed';
};

get '/index' => sub {
	debug "HOME";
	redirect '/facebook/login';
};





dance;
