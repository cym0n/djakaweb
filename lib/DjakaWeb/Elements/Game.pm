package DjakaWeb::Elements::Game;

use Moose;
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
has 'GameDB' => (
	  is     => 'ro',
);
has 'StatusDB' => (
	  is     => 'ro',
);
has 'StoryDB' => (
	  is     => 'ro',
);
has 'ActionsDB' => (
	  is     => 'ro',
);
has 'flags' => (
	  is     => 'rw',
);

my $meta = __PACKAGE__->meta;

around BUILDARGS => sub {
	my $orig  = shift;
    my $class = shift;
	my $params_ref = shift;
	my %params = %{$params_ref};
	my $game;
	my $schema = $params{'schema'};
	if(! $params{'id'})
	{
		#Fetching initial data from YAML files
		my $elements = DjakaWeb::StoryManager::getStartStatus($params{'mission'});
		my $story = DjakaWeb::StoryManager::getStory($params{'mission'});
		my $start_danger = DjakaWeb::StoryManager::getStartDanger($params{'mission'});
		#Writing the DB
		$game = $schema->resultset('Game')->init($params{'user'}, $params{'mission'}, $start_danger);
		$schema->resultset('GamesStatus')->init($game->id(), $elements);
		$schema->resultset('Story')->write_story($game->id(), $story);
	}	
	else
	{
		$game = $schema->resultset('Game')->find($params{'id'});
	}
	#Parameters collection
	$params{'id'} = $game->id();
	$params{'user'} = $game->user_id();
	$params{'mission'} = $game->mission_id();
	$params{'danger'} = $game->danger();
	$params{'GameDB'} =  $schema->resultset('Game');
	$params{'StatusDB'} =  $schema->resultset('GamesStatus');
	$params{'StoryDB'} =  $schema->resultset('Story');
	$params{'ActionsDB'} =  $schema->resultset('OngoingAction');
	my %flags;
	$flags{'nodanger'} = 0;
	$flags{'notell'} = 0;
	$params{'flags'} = \%flags;
	return $class->$orig(%params);
};

#Method to retrieve DB data
sub get_game
{
	my $self = shift;
	return $self->GameDB()->find($self->id());
}
sub get_status
{
	my $self = shift;
	return $self->StatusDB()->search({'game_id' => $self->id()});
}
sub get_story
{
	my $self = shift;
	return $self->StoryDB()->search({'game_id' => $self->id()});
}

#More complex getters :-)
sub get_elements
{
	my $self = shift;
	my %out;
	my $els = $self->get_status()->active_only();
	for(@{$els})
	{
		my $el = $_;
		my $el_name = DjakaWeb::StoryManager::getAttribute($self->mission(), $el, 'name');
		my $el_type = DjakaWeb::StoryManager::getAttribute($self->mission(), $el, 'type');
		my $el_data = { 'id' => $el,
			            'name' => $el_name};
		push @{$out{$el_type}}, $el_data;
	}
	return %out;
}
sub get_actions
{
	my $self = shift;
	my $element = shift;
	my $filter = shift;
	my $status = $self->get_status()->get_status($element);
	if($status eq "NOT_FOUND")
	{
		return undef;
	}
	elsif($status eq "NULL")
	{
		$status = 'ANY';
	}
	my %actions = DjakaWeb::StoryManager::getActions($self->mission(), $element, $status);
	if(! $filter)
	{
		return %actions;
	}
	else
	{
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
}

#Actions manager
sub do
{
	my $self = shift;
	my $element = shift;
	my $action = shift;
	my $author = shift;
	my $status = $self->get_status()->get_status($element);
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
	if(! ref $actions{$action})
	{
		return;
	}
	my $effects = $actions{$action};
	for(@{$effects})
	{
		my @eff = split(' ', $_);
		if($eff[0] =~ /^TAG$/)
		{
			$self->get_status()->tag($self->id(), $element, $eff[1]);
		}
		elsif($eff[0] =~ /^ADD$/)	
		{
			$self->get_status()->add($self->id(), $eff[1]);
		}
		elsif($eff[0] =~ /^REMOVE$/)	
		{
			$self->get_status()->remove($eff[1]);
		}
		elsif($eff[0] =~ /^TELL$/)
		{
			if(! ($self->flags()->{'notell'}))
			{
				if($self->get_status()->get_active($element) == 1)
				{
					my $story = DjakaWeb::StoryManager::getElementStory($self->mission(), $element, $eff[1]);
					$self->StoryDB()->write_story($self->id(), $story);
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
#Put action on schedule
sub schedule_action
{
	my $self = shift;
	my $element = shift;
	my $action = shift;
	$self->ActionsDB->add_action($self->id(), $element, $action);
}




#Story reader
sub get_all_story
{
	my $self = shift;
	return $self->get_story()->get_all_story('desc');
}

#Victory check
sub check_victory
{
	my $self = shift;
	my $victories = DjakaWeb::StoryManager::getVictory($self->mission());	
	for(keys %{$victories})
	{
		my $tag = $_;
		my $check = 1;
		for(keys %{$victories->{$tag}->{'condition'}})
		{
			my $status = $self->get_status($_);
			if(! ($status eq $victories->{$tag}->{'condition'}->{$_}))
			{ 
				$check = 0;
				last;
			}
		}
		return $tag if($check == 1);
	}
	return undef;
}

#Danger management
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
	$self->get_game()->write_danger($self->danger());
}


#Flag managers
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
	$self->get_status()->print_status();
}

1;
