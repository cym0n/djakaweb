package DjakaWeb::Elements::Game;

use Dancer;
use Moose;
use Dancer::Plugin::DBIC;
use DjakaWeb::StoryManager;


has 'id' => (
      is     => 'ro',
);
has 'user' => (
      is     => 'ro',
);
has 'mission' => (
      is     => 'ro',
);
has 'danger' => (
      is     => 'rw',
	  trigger => \&_update_danger
);
has 'DBData' => (
	  is     => 'ro',
);
has 'flags' => (
	  is     => 'rw',
);

my $meta = __PACKAGE__->meta;
my $schema = schema;
my $debug = 0;

around BUILDARGS => sub {
	my $orig  = shift;
    my $class = shift;
	my $params_ref = shift;
	my %params = %{$params_ref};
	if(! $params{'id'})
	{
		my $elements = DjakaWeb::StoryManager::getStartStatus($params{'mission'});
		my $story = DjakaWeb::StoryManager::getStory($params{'mission'});
		my $start_danger = DjakaWeb::StoryManager::getStartDanger($params{'mission'});
		my $new_game = $schema->resultset('Game')->initGame($params{'user'}, $params{'mission'}, $start_danger);
		$params{'id'} = $new_game->id();
		$params{'danger'} = $start_danger;
		$params{'DBData'} = $new_game;
		my %flags;
		$flags{'nodanger'} = 0;
		$flags{'notell'} = 0;
		$params{'flags'} = \%flags;
		$schema->resultset('GamesStatus')->initGame($params{'id'}, $params{'mission'}, $elements);
		$schema->resultset('Story')->writeStory($params{'id'}, $story);
		return $class->$orig(%params);
	}	
	else
	{
		my $game = $schema->resultset('Game')->find($params{'id'});
		$params{'user'} = $game->user_id();
		$params{'mission'} = $game->mission_id();
		$params{'danger'} = $game->danger();
		$params{'DBData'} = $game;
		my %flags;
		$flags{'nodanger'} = 0;
		$flags{'notell'} = 0;
		$params{'flags'} = \%flags;
		return $class->$orig(%params);
	}
};

sub no_danger
{
	my $self = shift;
	$self->flags()->{'nodanger'} = 1;
}
sub no_tell
{
	my $self = shift;
	$self->flags()->{'notell'} = 1;
}

sub getElements
{
	my $self = shift;
	my @types = ('person', 'place', 'object');
	my %out;
	for(@types)
	{
		my $t = $_;
		my @els_def;
		my $els = $schema->resultset('GamesStatus')->getElements($self->id(), $_);
		for(@{$els})
		{
			my $el = $_;
			my $el_name = DjakaWeb::StoryManager::getAttribute($self->mission(), $el, 'name');
			my $el_data = { 'id' => $el,
				            'name' => $el_name};
			push @els_def, $el_data;
		}
		$out{$t} = \@els_def;

	}
	return %out;
}

sub getActions
{
	my $self = shift;
	my $element = shift;
	my $status = $schema->resultset('GamesStatus')->getStatus($self->id(), $element);
	if(! $status)
	{
		$status = 'ANY';
	}
	my %actions = DjakaWeb::StoryManager::getActions($self->mission(), $element, $status);
	return %actions;
}

sub getEffectiveActions
{
	my $self = shift;
	my $element = shift;
	my $status = $schema->resultset('GamesStatus')->getStatus($self->id(), $element);
	if(! $status)
	{
		$status = 'ANY';
	}
	my %actions = DjakaWeb::StoryManager::getActions($self->mission(), $element, $status);
	my %eff_actions;
	for(keys %actions)
	{
		my $useful = 0;
		for(@{$actions{$_}})
		{
			my @eff = split ' ', $_;
			if(!($eff[0] =~ /TELL/) && !($eff[0] =~ /DANGER/))
			{
				$useful = 1;
			}
		}
		$eff_actions{$_} = $actions{$_} if($useful == 1);
	}
	return %eff_actions;
}
sub set_danger
{
	my $self = shift;
	my $danger = shift;
	$self->danger($danger);
}

sub modify_danger
{
	my $self = shift;
	my $danger = shift;
	$self->danger($self->danger() + $danger);
}
sub _update_danger
{
	my $self = shift;
	$self->DBData()->write_danger($self->danger());
}
sub gameover
{
	my $self = shift;
	return ($self->danger() > config->{'danger_threshold'});
}

sub do
{
	my $self = shift;
	my $element = shift;
	my $action = shift;
	my $author = shift;
	my $status = $schema->resultset('GamesStatus')->getStatus($self->id(), $element);
	if(! $status)
	{
		$status = 'ANY';
	}
	my %actions;
	if($author =~ /human/)
	{
		%actions = DjakaWeb::StoryManager::getActions($self->mission(), $element, $status);
	}
	elsif($author =~ /machine/)
	{
		%actions = DjakaWeb::StoryManager::getM2MActions($self->mission(), $element, $status);
	}
	print "$element [$status] doing [$action]\n" if($debug);
	if(! ref $actions{$action})
	{
		print "Not allowed" if($debug);
		return;
	}
	my $effects = $actions{$action};
	for(@{$effects})
	{
		print "   $_\n" if($debug);
		my @eff = split(' ', $_);
		if($eff[0] =~ /^TAG$/)
		{
			$schema->resultset('GamesStatus')->tag($self->id(), $self->mission(), $element, $eff[1]);
		}
		elsif($eff[0] =~ /^ADD$/)	
		{
			$schema->resultset('GamesStatus')->add($self->id(), $self->mission(), $eff[1]);
		}
		elsif($eff[0] =~ /^REMOVE$/)	
		{
			$schema->resultset('GamesStatus')->remove($self->id(), $self->mission(), $eff[1]);
		}
		elsif($eff[0] =~ /^TELL$/)
		{
			if(! ($self->flags()->{'notell'}))
			{
				if($schema->resultset('GamesStatus')->getActive($self->id(), $element) == 1)
				{
					my $story = DjakaWeb::StoryManager::getElementStory($self->mission(), $element, $eff[1]);
					$schema->resultset('Story')->writeStory($self->id(), $story);
				}
			}
		}	
		elsif($eff[0] =~ /^DO$/)
		{
			$self->do($eff[2], $eff[1], 'machine');
		}
		elsif($eff[0] =~ /^DANGER$/)
		{
			if(! ($self->flags()->{'nodanger'}))
			{
				$self->modify_danger($eff[1]);		
			}
		}
	}
}

sub getAllStory()
{
	my $self = shift;
	return $schema->resultset('Story')->getAllStory($self->id(), 'desc');
}

sub check_victory()
{
	my $self = shift;
	my $victories = DjakaWeb::StoryManager::getVictory($self->mission());	
	for(keys %{$victories})
	{
		my $tag = $_;
		my $check = 1;
		for(keys %{$victories->{$tag}->{'conditions'}})
		{
			my $status = $schema->resultset('GamesStatus')->getStatus($self->id(), $_);
			$status = $status ? $status : "";
			if(! ($status eq $victories->{$tag}->{$_}))
			{ 
				$check = 0;
				last;
			}
		}
		return $tag if($check == 1);
	}
	return undef;
}


sub printClass
{
	my $self = shift;
	for my $attr ( $meta->get_all_attributes ) 
	{
    	print $attr->name, ": ", $self->{$attr->name}, "\n";
  	}
}
sub printStatus
{
	my $self = shift;
	$schema->resultset('GamesStatus')->printStatus($self->id());
}

1;
