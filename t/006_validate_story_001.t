use Test::More import => ['!pass'], tests => 9;
use Data::Dumper;
use strict;
use warnings;
use v5.10;

use Dancer;
use DjakaWeb;

my $storymanager = DjakaWeb::StoryManager->new({'path' => config->{'stories_path'}, 'story' => '001'});
my @els = qw(0000 0001 0002 0003 0004 0005 0006 0007 0008);

for(@els)
{
    isnt $storymanager->openYAML($_), undef, "$_ YAML syntax checked";
}
