package DjakaWeb::StoryManager;

use YAML::Tiny;

$debug = 0;

sub getStory
{
	my $story = shift;
	my $yaml = openYAML($story, 'START');
	return processText($yaml->[0]->{briefing}, $story, 'START');
}
sub getStartStatus
{
	my $story = shift;
	my $yaml = openYAML($story, 'START');
	return $yaml->[0]->{'elements'};
}
sub getStartDanger
{
	my $story = shift;
	my $yaml = openYAML($story, 'START');
	return $yaml->[0]->{'start_danger'};
}
sub getActions
{
	my $story = shift;
	my $element = shift;
	my $status = shift;
	return getAnyActions($story, $element, $status, 'actions');
}
sub getM2MActions
{
	my $story = shift;
	my $element = shift;
	my $status = shift;
	return getAnyActions($story, $element, $status, 'm2m');
}
sub getVictory
{
	my $story = shift;
	my $yaml = openYAML($story, 'END');
	return $yaml->[0];
}
sub getAnyActions
{
	my $story = shift;
	my $element = shift;
	my $status = shift;
	my $which = shift;
	my $yaml = openYAML($story, $element);
	my $actions_grid = $yaml->[0]->{$which};
	my %actions;
	for(keys %{$actions_grid})
	{
		my $a = $_;
		my $a_with_status;
		if(! $actions_grid->{$a}->{$status})
		{
			$a_with_status = $actions_grid->{$a}->{'ANY'}
		}
		else
		{
			$a_with_status = $actions_grid->{$a}->{$status};
		}
		if(ref $a_with_status)
		{
			$actions{$a} = $a_with_status;
		}
	}
	return %actions;
}
sub openYAML
{
	$story = shift;
	$code = shift;
	my $yaml = YAML::Tiny->new;
	my $file = "stories/" . $story . "_" . $code . ".yml";
	print "$file\n" if($debug);
	$yaml = YAML::Tiny->read($file);
	return $yaml;

}

sub processText
{
	my $text = shift;
	my $story = shift;
	my $code = shift;
	return "" if(! $text);
	$text =~ s/(\{.*?\})/<strong>$1<\/strong>/g;
	$text =~ s/\{(.*?)\}/getAttribute($story, $code, $1)/eg;
	return $text;
}

sub getElementStory
{
	my $story = shift;
	my $code = shift;
	my $tag = shift;
	$yaml = openYAML($story, $code);
	return processText($yaml->[0]->{'messages'}->{$tag}, $story, $code);
}
sub getAttribute
{
	my $story = shift;
	my $code = shift;
	my $attribute = shift;
	print "Getting attribute for $attribute\n" if($debug);
	if($attribute =~ /\./)
	{
		($code, $attribute) = split('\.', $attribute);
	}
	$yaml = openYAML($story, $code);
	print $yaml->[0]->{$attribute} if($debug);	
	return $yaml->[0]->{$attribute};	
}


1;

