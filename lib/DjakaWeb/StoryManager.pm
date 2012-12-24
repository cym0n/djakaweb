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

sub allowed_stories
{
    my $self = shift;
    opendir (my $DIR, $self->path()) or die $!;
    my @stories;
    while (my $file = readdir($DIR)) {
        if($file =~ /^(.*?)_START.yml/)
        {
            my $story = $1;
            my $yaml = $self->openYAML_nostory($story, 'START');
            push @stories, {code => $story, title => $yaml->[0]->{'title'}};
        }
    }
    return @stories;
}


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
        my $real_status;
		if(! $actions_grid->{$a}->{$status})
		{
			$a_with_status = $actions_grid->{$a}->{'ANY'};
            $real_status = 'ANY';
		}
		else
		{
			$a_with_status = $actions_grid->{$a}->{$status};
            $real_status = $status;
		}
		if(ref $a_with_status) #In YAML sintax '%action%: KO' makes this test return false
		{
			$actions{$a}->{'effects'} = $a_with_status;
            $actions{$a}->{'real status'} = $real_status;
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
sub openYAML_nostory
{
	my $self = shift;
    my $story = shift;
	my $code = shift;
	my $yaml = YAML::Tiny->new;
	my $file = $self->path() . "/" . $story . "_" . $code . ".yml";
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
sub getDangerStory
{
	my $self = shift;
	my $level = shift;
	if($level > 0)
	{
		return "Il livello di tensione si è alzato di " . $level . '.';
	}
	else
	{
		return "Il livello di tensione si è abbassato di " . $level*-1 . '.';;
	}
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


sub testElement
{
    my $self = shift;
    my $code = shift;
    my $coherence = shift;
    my $element = $self->openYAML($code);
    
    my $all_status = 1;
    my $all_tags = 1;
    my $all_tells = 1;
    my $messages_syntax = 1;
    my $do_syntax = 1;
    
    my %status;
    my @tags;
    my @tells;
    for(('actions', 'm2m'))
    {
        my $type = $_;
        my $actions_grid = $element->[0]->{$type};
        for(keys %{$actions_grid})
        {
            my $a = $_;
            for(keys %{$actions_grid->{$a}})
            {
                my $s = $_;
                $status{$s} = 1;
                if(ref $actions_grid->{$a}->{$s})
                {
                    for(@{$actions_grid->{$a}->{$s}})
                    {
                        my $order = $_;
                        if($order =~ /^TAG (.*)$/)
                        {
                            push @tags, $1;
                        }
                        if($order =~ /^TELL (.*)$/)
                        {
                            push @tells, $1;
                        }
                        if($order =~ /^DO (.*)$/)
                        {
                            if($1 !~ /[A-Z]*? \d\d\d\d/)
                            {
                                $do_syntax = 0;
                                print $1;
                            }

                        }
                    }
                }
            }
        }
    }
    delete $status{'ANY'};
    for(@tags)
    {
        if(! $status{$_})
        {
            $all_tags = 0;
        }
        else
        {
            $status{$_} = 2;
        }
    }
    for(keys %status)
    {
        if($status{$_} == 1)
        {
            $all_status = 0;
        }
    }
    for(@tells)
    {
        if(! $element->[0]->{'messages'}->{$_})
        {
            $all_tells = 0;
        }
        else
        {
            for($element->[0]->{'messages'}->{$_} =~ /\{(.*?)\}/g)
            {
                my $token = $_;
                if($token && $token !~ /^(\d\d\d\d\.)?name$/)
                {
                   $messages_syntax = 0; 
                }
            }
        }
    }
    if($coherence eq 'status')
    {
        return $all_status;
    }
    elsif($coherence eq 'tags')
    {
        return $all_tags;
    }
    elsif($coherence eq 'tells')
    {
        return $all_tells;
    }
    elsif($coherence eq 'messages')
    {
        return $messages_syntax;
    }
    elsif($coherence eq 'do')
    {
        return $do_syntax;
    }
    else
    {
        return $all_status && $all_tags && $all_tells && $messages_syntax && $do_syntax;
    }
    

}



1;

