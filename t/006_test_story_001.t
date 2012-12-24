use Test::More import => ['!pass'], tests => 54;
use Data::Dumper;
use strict;
use warnings;
use v5.10;

use Dancer;
use DjakaWeb;

my $storymanager = DjakaWeb::StoryManager->new({'path' => config->{'stories_path'}, 'story' => '001'});
my @els = qw(0000 0001 0002 0003 0004 0005 0006 0007 0008);
my @good = (1, 1, 1);
for(@els)
{
    isnt $storymanager->openYAML($_), undef, "$_ YAML syntax checked";
    is $storymanager->testElement($_, 'tags'), 1, "Every status reached by $_ is managed somewhere";
    is $storymanager->testElement($_, 'status'), 1, "Every status of $_ has a TAG command that activate it";
    is $storymanager->testElement($_, 'tells'), 1, "Every TELL of $_ has a message";
    is $storymanager->testElement($_, 'messages'), 1, "Every token in every message in $_ has the right syntax";
    is $storymanager->testElement($_, 'do'), 1, "Every do command in $_ has the right syntax";
}
