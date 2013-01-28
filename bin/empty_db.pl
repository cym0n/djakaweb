use strict;
use warnings;
use v5.10;

use Dancer;
use Dancer::Plugin::DBIC;
use DjakaWeb;

schema->resultset("Click")->delete_all();
schema->resultset("GamesStatus")->delete_all();
schema->resultset("Story")->delete_all();
schema->resultset("OngoingAction")->delete_all();
schema->resultset("Game")->delete_all();
schema->resultset("User")->delete_all();
