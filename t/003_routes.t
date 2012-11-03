use Test::More import => ['!pass'], tests => 6;
use Data::Dumper;
use strict;
use warnings;
use v5.10;

# the order is important
use Dancer;
use DjakaWeb;
use Dancer::Test;

my $routes = [{ route => '/', answer => 302},
              { route => '/facebook/login', answer => 200},
              { route => '/game/dashboard', answer => 200}];

config->{facebook}->{stubbed} = 1;
config->{facebook}->{fake_id} = 100;

for(@$routes)
{
    my %r = %$_;
    route_exists [GET => $r{'route'}], "a route handler is defined for " . $r{'route'};
    response_status_is ['GET' => $r{'route'}], $r{'answer'}, "response status is " . $r{'answer'} . " for " . $r{'route'};
}
