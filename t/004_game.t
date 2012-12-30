use Test::More import => ['!pass'], tests => 24;
use Data::Dumper;
use strict;
use warnings;
use v5.10;

use Dancer;
use Dancer::Test;
use DjakaWeb;

my $fake_facebook_id = 100;
my $test_mission = '000';
my $test_object = '0000';
my $test_action = 'BRIBE';

#Fake user configuration
diag("A fake facebook user will be user. System login stubbed");
config->{facebook}->{stubbed} = 1;
config->{facebook}->{fake_id} = $fake_facebook_id;

#Access to the homepage
diag("First access tests");
route_exists [GET => '/game/dashboard'], "a route handler is defined for " . '/game/dashboard';
response_status_is ['GET' => '/game/dashboard'], 302, "response status is 302 for " . '/game/dashboard' . ' because no mission is selected';
diag("Mission configuration tests");
route_exists [GET => '/game/missions'], "a route handler is defined for " . '/game/dashboard' . ' (GET)';
route_exists [POST => '/game/missions'], "a route handler is defined for " . '/game/dashboard' . ' (GET)';
diag("Access to the mission selection page - GET");
response_status_is ['GET' => '/game/missions'], 200, "response status is 200 for " . '/game/missions';
diag("POST value simulated. Submit mission selection - POST");
$ENV{'QUERY_STRING'} = "mission=$test_mission";
response_status_is ['POST' => '/game/missions'], 302, "response status is 302 for " . '/game/missions' . ' (POST) because of the submit of the mission';
diag("Access to dashboard test");
response_status_is ['GET' => '/game/dashboard'], 200, "response status is 200 for " . '/game/dashboard' . '. We have a mission.';
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
my $user = DjakaWeb::Controllers::get_user('facebook_id' => $fake_facebook_id);
my $game = $user->get_active_game();
my $active_action = $game->get_active_action();
is $active_action->{object_code}, $test_object, "Object of the ongoing action correctly configured";
is $active_action->{action}, $test_action, "Action of the ongoing action correctly configured";
is $active_action->{clicks}, 2, "Clicks of the ongoing action correctly configured";

#TODO
#Costruire un caso di test per i click di supporto


