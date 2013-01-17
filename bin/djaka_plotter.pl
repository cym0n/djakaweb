#!/usr/bin/perl

use Dancer;
use Dancer::Plugin::DBIC;
use DjakaWeb;
use Data::Dumper;

my $choose = $ARGV[0];
my $node;
if($choose)
{
    $node = schema->resultset('TestGraph')->find({ id => $choose});
}
else
{
    my @wins = schema->resultset('TestGraph')->search({ finish => -2});
    my $win = shift @wins;
    $node = $win;
}
my $danger_row = schema->resultset('TestStatus')->find({ status_id => $node->start(), 'object_code' => 'DANGER'});
print "Danger for the final state is: " . $danger_row->status() . "\n";
print "Path:\n";
while($node->start() != 0)
{
    $node->print();
    my @nodes = schema->resultset('TestGraph')->search({ finish => $node->start()});
    $node = shift @nodes; 
}
$node->print();
