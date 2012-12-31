use Test::More import => ['!pass'], tests => 34;
use Data::Dumper;
use strict;
use warnings;
use v5.10;

use Dancer;
use Dancer::Test;
use Dancer::Plugin::DBIC; #needed to empty the db
use DjakaWeb;

my $fake_facebook_id_A = 100;
my $fake_facebook_id_B = 200;
my $test_mission = '000';
my $test_object = '0000';
my $test_action = 'BRIBE';
my $action_url = '/game/do/' . $test_action . '/' . $test_object;
my $fake_support_url = '/game/help/99';
my $fake_support_click = $fake_support_url . '/click';


diag(" --- WINNING SCENARIO --- ");

diag("Empty test database");
empty_db();

diag("Check route existence");
    route_exists [GET => '/game/dashboard'], "a route handler is defined for " . '/game/dashboard';
    route_exists [GET => '/game/missions'], "a route handler is defined for " . '/game/missions' . ' (GET)';
    route_exists [POST => '/game/missions'], "a route handler is defined for " . '/game/missions' . ' (GET)';
    route_exists [GET => '/game/service/description/0000'], "a route handler is defined for " . '/game/service/description/0000';
    route_exists [GET => '/game/service/actions/0000'], "a route handler is defined for " . '/game/service/actions/0000';
    route_exists [GET => $action_url], "a route handler is defined for " . $action_url;
    route_exists [GET => $fake_support_url], "a route handler is defined for $fake_support_url";
    route_exists [GET => $fake_support_click], "a route handler is defined for $fake_support_click";


check_identity();
#Fake user configuration
diag("A fake facebook user will be user. System login stubbed");
config->{facebook}->{stubbed} = 1;
config->{facebook}->{fake_id} = $fake_facebook_id_A;

#Access to the homepage
diag("First access tests");
    response_status_is ['GET' => '/game/dashboard'], 302, "response status is 302 for " . '/game/dashboard' . ' because no mission is selected';
check_identity();
diag("Mission configuration tests");
diag("Access to the mission selection page - GET");
    response_status_is ['GET' => '/game/missions'], 200, "response status is 200 for " . '/game/missions';
diag("POST value simulated. Submit mission selection - POST");
    $ENV{'QUERY_STRING'} = "mission=$test_mission";
    response_status_is ['POST' => '/game/missions'], 302, "response status is 302 for " . '/game/missions' . ' (POST) because of the submit of the mission';
diag("Access to dashboard test");
    response_status_is ['GET' => '/game/dashboard'], 200, "response status is 200 for " . '/game/dashboard' . '. We have a mission.';
diag("Objects menu check - descriptions");
    response_status_is ['GET' => '/game/service/description/0000'], 200, "Actions for 0000 correctly retrieved";
    response_status_is ['GET' => '/game/service/description/0001'], 200, "Actions for 0001 correctly retrieved";
    response_status_is ['GET' => '/game/service/description/0002'], 200, "Actions for 0002 correctly retrieved";

diag("Objects menu check - actions");
    response_status_is ['GET' => '/game/service/actions/0000'], 200, "Actions for 0000 correctly retrieved";
    response_status_is ['GET' => '/game/service/actions/0001'], 200, "Actions for 0001 correctly retrieved";
    response_status_is ['GET' => '/game/service/actions/0002'], 200, "Actions for 0002 correctly retrieved";

diag("Select an action");
    response_redirect_location_is ['GET' => $action_url], 'http://localhost/game/dashboard';
    response_redirect_location_is ['GET' => $action_url], 'http://localhost/game/courtesy/bad_action';

diag("Clicks");
    response_redirect_location_is ['GET' => '/game/click'], 'http://localhost/game/courtesy/bad_click';
diag("Waiting...");
    sleep 7;
    response_redirect_location_is ['GET' => '/game/click'], 'http://localhost/game/dashboard';

diag("Situation check on DB");
    my ($user, $game) = DjakaWeb::Controllers::build_elements();
    my $active_action = $game->get_active_action();
    is $active_action->{object_code}, $test_object, "Object of the ongoing action correctly configured";
    is $active_action->{action}, $test_action, "Action of the ongoing action correctly configured";
    is $active_action->{clicks}, 2, "Clicks of the ongoing action correctly configured";

    my $ongoing_action_id = $active_action->{'id'};
    my $support_url = '/game/help/' . $ongoing_action_id;
    my $support_click = $support_url . '/click';

diag("Here come the second user for support click");
    flush_identity();
check_identity();
    config->{facebook}->{fake_id} = $fake_facebook_id_B;

diag("Access of the second user");
    response_status_is ['GET' => '/game/dashboard'], 302, "response status is 302 for " . '/game/dashboard' . ' because no mission is selected';
check_identity();
    response_status_is ['GET' => $support_url], 200, "response status is 200 for " . $support_url;
    response_redirect_location_is ['GET' => $support_click], 'http://localhost/game/help/courtesy/good_click', "Support click $support_click went well";
    $active_action = $game->get_active_action();
    is $active_action->{clicks}, 3, "Clicks of the ongoing action correctly configured (after support)";

diag("Back to the first user for win test");
    flush_identity();
check_identity();
    config->{facebook}->{fake_id} = $fake_facebook_id_A;
diag("Access back of the first user");
    response_status_is ['GET' => '/game/dashboard'], 200, "response status is 200 for " . '/game/dashboard' . ' because we already have a mission';
check_identity();
diag("Waiting...");
    sleep 7;
diag("Winning scenario");
    response_redirect_location_is ['GET' => '/game/click'], 'http://localhost/game/win';
    $game = schema->resultset("Game")->find($game->id);
    is $game->active, 2, "The game is in the correct win status";
    is $game->games_statuses->find({object_code => $test_object})->status, 'BRIBED', "$test_object is BRIBED";
    $active_action = $game->get_active_action();
    is $active_action->{'action'}, 'NONE', "No active action";

print Dumper(read_logs);



sub empty_db
{
    schema->resultset("Click")->delete_all();
    schema->resultset("GamesStatus")->delete_all();
    schema->resultset("Story")->delete_all();
    schema->resultset("OngoingAction")->delete_all();
    schema->resultset("Game")->delete_all();
    schema->resultset("User")->delete_all();
}

sub check_identity
{
    my ($user, $game) = DjakaWeb::Controllers::build_elements();
    if($user)
    {
        diag("Impersoning " . $user->id);
    }
    else
    {
        diag("No user");
    }
}

sub flush_identity
{
    session 'user' => undef;
    session 'game' => undef;
}


