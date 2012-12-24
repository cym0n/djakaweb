#!/usr/bin/perl

use Dancer;
use Dancer::Plugin::DBIC;
use DjakaWeb;
use Data::Dumper;

my $mission = '001';
my $user_id = 999;

my @types = ('person', 'place', 'object');

my $game = DjakaWeb::Elements::Game->new({'user' => $user_id, 'mission' => $mission, 'stories_path' => config->{'stories_path'}});

my $game_id = $game->id();
my $analyse_cursor = 0;
my $add_cursor = 0;
my $max_length = 12;
my %lengths;

my @start_status = schema->resultset('GamesStatus')->snapshot($game_id);
schema->resultset('TestStatus')->saveSnapshot($add_cursor, \@start_status, $game->danger());
$lengths{0} = 0;
while(1)
{
    my %els = $game->get_elements();
    my @options;
    for(@types)
    {
        my $t = $_;
        for(@{$els{$t}})
        {
            my $id = $_->{'id'};
            my %acts = $game->get_actions($id, 1);
            for(keys %acts)
            {
                push @options, {'element' => $id, 'action' => $_};
            }
        }
    }
    for(@options)
    {
        my $element = $_->{'element'};
        my $action = $_->{'action'};
        my @new_status = schema->resultset('TestStatus')->getSnapshot($analyse_cursor);
		my $danger_snap = schema->resultset('GamesStatus')->overwrite($game_id, \@new_status);
		$game->set_danger($danger_snap);
        $game->schedule_action($element, $action);
        $game->do_active_action();
        my $danger = $game->danger();
        if($danger >= 100)
        {
            #GAME OVER
            print "========== GAMEOVER REACHED\n";
            schema->resultset('TestGraph')->writeArc($analyse_cursor, $element, $action, -1);
        }
        else
        {
            if(my $vic = $game->check_victory())
            {
                print "========== VICTORY STATUS REACHED: $vic\n";
                schema->resultset('TestGraph')->writeArc($analyse_cursor, $element, $action, -2);
            }
            else
            {
   				my @snapshot = schema->resultset('GamesStatus')->snapshot($game_id);
				my $present = schema->resultset('TestStatus')->compareToSnapshot(\@snapshot, $danger);
				if($present == -1)
				{
					schema->resultset('TestStatus')->saveSnapshot(++$add_cursor, \@snapshot, $danger);
					$lengths{$add_cursor} = $lengths{$analyse_cursor} + 1;
					schema->resultset('TestGraph')->writeArc($analyse_cursor, $element, $action, $add_cursor);
				}
				else
				{
					schema->resultset('TestGraph')->writeArc($analyse_cursor, $element, $action, $present);
				}
            }
        }
    }
    $analyse_cursor++;
	while($lengths{$analyse_cursor} > $max_length)
	{
		$analyse_cursor++;
	}
	my @new_status = schema->resultset('TestStatus')->getSnapshot($analyse_cursor);
	if($#new_status == -1)
	{
		last;
	}
	else
	{	
		my $danger_snap = schema->resultset('GamesStatus')->overwrite($game_id, \@new_status);
		$game->set_danger($danger_snap);
	}
}
