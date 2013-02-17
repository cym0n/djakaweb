package DjakaWeb;
use Dancer ':syntax';
use Dancer::Template::TemplateToolkit;
use DjakaWeb::Controllers;

our $VERSION = '0.1';

my @game_not_needed_path = (qr/^\/game\/help/, 
                            qr/^\/game\/missions/,
                            qr/^\/game\/gameover/,
                            );

hook 'before' => sub {
    DjakaWeb::Controllers::build_elements();
	#game navigations are only for logged users
	if(request->path_info =~ /^\/game/)
	{
		if(! session('user'))
		{
			my $fblogin = DjakaWeb::Controllers::facebook_data;
			if($fblogin == 0)
			{
				redirect '/facebook/login?returl=' . request->path_info;
                return 0;
			}
		}
        if( ! session('game') && ! map { request->path_info =~ $_ ? (1) : () } @game_not_needed_path )
        {
				redirect '/game/missions';
                return 0;
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


#Missions
get '/game/missions' => sub {
    template 'missions' => DjakaWeb::Controllers::get_missions();
};

post '/game/missions' => sub {
    DjakaWeb::Controllers::assign_mission(params->{mission});
	redirect '/game/dashboard';
};

#Game navigations
get '/game/dashboard' => sub {
	template 'interface' => DjakaWeb::Controllers::get_data_for_interface(), {'layout' => 'interface.tt'};
};
get '/game/help/:action_id/click' => sub {
	my $result = DjakaWeb::Controllers::support_click(params->{action_id});
	if($result == DjakaWeb::Controllers::CLICK_ERROR || $result == DjakaWeb::Controllers::CLICK_TIMEOUT)
	{
		redirect '/game/help/courtesy/bad_click';
	}
	else
	{
		redirect '/game/help/courtesy/good_click';
	}
};
get '/game/help/:action_id' => sub {
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

get '/game/click' => sub {
	my $result = DjakaWeb::Controllers::click();
	if($result == DjakaWeb::Controllers::GAME_LOST)
	{
		redirect '/game/gameover';
        return 0;
	}
	elsif($result == DjakaWeb::Controllers::GAME_WON)
	{
		redirect '/game/win';
	}
	elsif($result == DjakaWeb::Controllers::CLICK_ERROR || $result == DjakaWeb::Controllers::CLICK_TIMEOUT)
	{
		redirect '/game/courtesy/bad_click';
        return 0;
	}
	else
	{
		redirect '/game/dashboard';
        return 0;
	}
};
get '/game/gameover' => sub {
	if(session('end') =~ /^__GAMEOVER__$/)
	{
        session 'end' => undef;
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
		template 'win' => DjakaWeb::Controllers::victory(session('end'));
	}
	else
	{
		redirect '/game/dashboard';
	}
};

#Info pages
get '/info/description' => sub {
    template 'rules'
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
get '/game/help/courtesy/good_click' => sub {
	template 'good_click';
};
get '/game/help/courtesy/bad_click' => sub {
	template 'bad' => { 'message' => 'Il click non &egrave; andato a buon fine'};
};
get '/game/courtesy/bad_click' => sub {
	template 'bad' => { 'message' => 'Il click non &egrave; andato a buon fine'};
};
get '/game/courtesy/bad_action' => sub {
	template 'bad' => { 'message' => 'La selezione dell\'azione non &egrave; andata a buon fine'};
};

1;
