package DjakaWeb;
use Dancer ':syntax';
use Dancer::Template::TemplateToolkit;
use DjakaWeb::Controllers;

our $VERSION = '0.1';


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
};

hook 'before_template_render' => sub {
	my $tokens = shift;
	if(request->path_info =~ /^\/game/)
	{
		my $badge = DjakaWeb::Controllers::get_data_for_badge;
		$tokens->{username} = $badge->{username};
		$tokens->{avatar} = $badge->{avatar};
	}
	$tokens->{env} = config->{environment};
};

#Redirect to real pages
get '/' => sub {
	redirect '/game/dashboard';
};

get '/game' => sub {
	redirect '/game/dashboard';
};

#Login
get '/facebook/login' => sub {
	template 'facebook_access' => { 'fb_app_id' => config->{facebook}->{'app_id'},
	                                'returl' => request->{params}->{returl}};
};

#Game navigations
get '/game/dashboard' => sub {
	template 'interface' => DjakaWeb::Controllers::get_data_for_interface(), {'layout' => 'interface.tt'};
};
get '/share/help/:action_id' => sub {
	my $data = DjakaWeb::Controllers::get_data_for_help(params->{action_id});
	#if($data->{'errors'} eq 'BAD_ACTION')
	#{
	#	return Dancer::Response->new(
	#    	status => 404,
	#    	content => 'Bad action id'
	#	);
	#}
	#if($data->{'errors'} eq 'SAME_USER')
	#{
	#	redirect '/game/dashboard';
	#}	
	template 'help' => $data, {'layout' => 'help' };
};
get '/game/do/:action/:element' => sub {
	my $result = DjakaWeb::Controllers::schedule_action(params->{element}, params->{action});
	if($result == DjakaWeb::Controllers::GAME_LOST)
	{
		redirect '/game/gameover';
	}
	elsif($result == DjakaWeb::Controllers::GAME_WON)
	{
		redirect '/game/win';
	
	}
	elsif($result == DjakaWeb::Controllers::CLICK_ERROR)
	{
		redirect '/game/courtesy/bad_click';
	}
	elsif($result == DjakaWeb::Controllers::ACTION_ERROR)
	{
		redirect '/game/courtesy/bad_action';
	}
    else
    {
	    redirect '/game/dashboard';
    }
};
get '/game/help/:action_id/click' => sub {
	my $result = DjakaWeb::Controllers::support_click(params->{action_id});
	if($result == DjakaWeb::Controllers::CLICK_ERROR)
	{
		redirect '/game/courtesy/bad_click';
	}
	else
	{
		redirect '/game/courtesy/good_click';
	}
};
get '/game/click' => sub {
	my $result = DjakaWeb::Controllers::click();
	if($result == DjakaWeb::Controllers::GAME_LOST)
	{
		redirect '/game/gameover';
	}
	elsif($result == DjakaWeb::Controllers::GAME_WON)
	{
		redirect '/game/win';
	
	}
	elsif($result == DjakaWeb::Controllers::CLICK_ERROR)
	{
		redirect '/game/courtesy/bad_click';
	}
	else
	{
		redirect '/game/dashboard';
	}
};
get '/game/gameover' => sub {
	if(session('end') =~ /^__GAMEOVER__$/)
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
get '/game/courtesy/good_click' => sub {
	template 'good_click';
};
get '/game/courtesy/bad_click' => sub {
	template 'bad' => { 'message' => 'Il click non &egrave; andato a buon fine'};
};
get '/game/courtesy/bad_action' => sub {
	template 'bad' => { 'message' => 'La selezione dell\'azione non &egrave; andata a buon fine'};
};

1;
