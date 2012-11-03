use Test::More import => ['!pass'], tests => 18;
use Data::Dumper;
use strict;
use warnings;
use v5.10;

# the order is important
use Dancer;
use DjakaWeb;
use Dancer::Test;

my $fake_facebook_id = 100;
my $test_object = '0000';
my $test_action = 'BRIBE';

#Fake user configuration
diag("A fake facebook user will be user. System login stubbed");
config->{facebook}->{stubbed} = 1;
config->{facebook}->{fake_id} = $fake_facebook_id;

#Access to the homepage
diag("Homepage tests");
route_exists [GET => '/game/dashboard'], "a route handler is defined for " . '/game/dashboard';
response_status_is ['GET' => '/game/dashboard'], 200, "response status is 200 for " . '/game/dashboard';
diag("If response status is a redirect probably stubbed login failed");

diag("Objects menu check - descriptions");
route_exists [GET => '/game/service/description/0000'], "a route handler is defined for " . '/game/service/description/0000';
diag("Just one check for route existence");
response_status_is ['GET' => '/game/service/description/0000'], 200, "Actions for 0000 correctly retrieved";
response_status_is ['GET' => '/game/service/description/0001'], 200, "Actions for 0001 correctly retrieved";
response_status_is ['GET' => '/game/service/description/0002'], 200, "Actions for 0002 correctly retrieved";

diag("Objects menu check - actions");
route_exists [GET => '/game/service/actions/0000'], "a route handler is defined for " . '/game/service/actions/0000';
diag("Just one check for route existence");
response_status_is ['GET' => '/game/service/actions/0000'], 200, "Actions for 0000 correctly retrieved";
response_status_is ['GET' => '/game/service/actions/0001'], 200, "Actions for 0001 correctly retrieved";
response_status_is ['GET' => '/game/service/actions/0002'], 200, "Actions for 0002 correctly retrieved";

diag("Select an action");
my $action_url = '/game/do/' . $test_action . '/' . $test_object;
route_exists [GET => $action_url], "a route handler is defined for " . $action_url;
response_redirect_location_is ['GET' => $action_url], 'http://localhost/game/dashboard';
response_redirect_location_is ['GET' => $action_url], 'http://localhost/game/courtesy/bad_action';

diag("Click. (you have to await one minute to have a good click)");
route_exists [GET => '/game/click'], "a route handler is defined for " . '/game/click';
response_redirect_location_is ['GET' => '/game/click'], 'http://localhost/game/courtesy/bad_click';
diag("Waiting a minute...");
sleep 60;
response_redirect_location_is ['GET' => '/game/click'], 'http://localhost/game/dashboard';

diag("Checks on user status");
my $user = DjakaWeb::Elements::User->new({'facebook_id' => $fake_facebook_id});
my $game_id = DjakaWeb::Elements::Game::get_active_game($user->id());
my $game = DjakaWeb::Elements::Game->new({'id' => $game_id, 'stories_path' => config->{'stories_path'}});
my $active_action = $game->get_active_action();
is $active_action->{object_code}, $test_object, "Object of the ongoing action correctly configured";
is $active_action->{action}, $test_action, "Action of the ongoing action correctly configured";


