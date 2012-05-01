package DjakaWeb::StoryManager;

use Moose;
use YAML::Tiny;

has 'story' => (
      is     => 'ro',
);
has 'path' => (
      is     => 'ro',
);

my $meta = __PACKAGE__->meta;
my $debug = 0;


around BUILDARGS => sub {
	my $orig  = shift;
    my $class = shift;
	my $params_ref = shift;
	my %params = %{$params_ref};
	return $class->$orig(%params);
};


sub getStory
{
	my $self = shift;
	my $yaml = $self->openYAML('START');
	return $self->processText($yaml->[0]->{briefing}, 'START');
}
sub getStartStatus
{
	my $self = shift;
	my $yaml = $self->openYAML('START');
	return $yaml->[0]->{'elements'};
}
sub getStartDanger
{
	my $self = shift;
	my $yaml = $self->openYAML('START');
	return $yaml->[0]->{'start_danger'};
}
sub getActions
{
	my $self = shift;
	my $element = shift;
	my $status = shift;
	return $self->getAnyActions($element, $status, 'actions');
}
sub getM2MActions
{
	my $self = shift;
	my $element = shift;
	my $status = shift;
	return $self->getAnyActions($element, $status, 'm2m');
}
sub getVictory
{
	my $self = shift;
	my $yaml = $self->openYAML('END');
	return $yaml->[0];
}
sub getAnyActions
{
	my $self = shift;
	my $element = shift;
	my $status = shift;
	my $which = shift;
	my $yaml = $self->openYAML($element);
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
	my $self = shift;
	my $code = shift;
	my $yaml = YAML::Tiny->new;
	my $file = $self->path() . "/" . $self->story() . "_" . $code . ".yml";
	print "$file\n" if($debug);
	$yaml = YAML::Tiny->read($file);
	return $yaml;
}

sub processText
{
	my $self = shift;
	my $text = shift;
	my $code = shift;
	return "" if(! $text);
	$text =~ s/(\{.*?\})/<strong>$1<\/strong>/g;
	$text =~ s/\{(.*?)\}/$self->getAttribute($code, $1)/eg;
	return $text;
}

sub getElementStory
{
	my $self = shift;
	my $code = shift;
	my $tag = shift;
	my $yaml = $self->openYAML($code);
	return $self->processText($yaml->[0]->{'messages'}->{$tag}, $code);
}
sub getElementDescription
{
	my $self = shift;
	my $code = shift;
	my $status = shift;
	my $yaml = $self->openYAML($code);
	my $description = $self->processText($yaml->[0]->{'description'}->{'START'}, $code);
	$description .= "\n";
	if($status)
	{
		$description .= $self->processText($yaml->[0]->{'description'}->{$status}, $code);
	}
	return $description;
}
sub getAttribute
{
	my $self = shift;
	my $code = shift;
	my $attribute = shift;
	print "Getting attribute for $attribute\n" if($debug);
	if($attribute =~ /\./)
	{
		($code, $attribute) = split('\.', $attribute);
	}
	my $yaml = $self->openYAML($code);
	print $yaml->[0]->{$attribute} if($debug);	
	return $yaml->[0]->{$attribute};	
}


1;

