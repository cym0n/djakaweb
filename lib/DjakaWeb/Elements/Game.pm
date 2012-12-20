package DjakaWeb::Elements::Game;

use Moose;
use DjakaWeb::StoryManager;
use Dancer::Plugin::DBIC;


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
has 'StoryManager' => (
	  is     => 'ro',
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
	my $storymanager;
	my $schema = schema;
	if(! $params{'id'})
	{
		$storymanager = DjakaWeb::StoryManager->new({'path' => $params{'stories_path'}, 'story' => $params{'mission'}});
		#Fetching initial data from YAML files
		my $elements = $storymanager->getStartStatus();
		my $story = $storymanager->getStory();
		my $start_danger = $storymanager->getStartDanger();
		#Writing the DB
		$game = $schema->resultset('Game')->init($params{'user'}, $params{'mission'}, $start_danger);
		$schema->resultset('GamesStatus')->init($game->id(), $elements);
		$schema->resultset('Story')->write_story($game->id(), $story);
	}	
	else
	{
		$game = $schema->resultset('Game')->find($params{'id'});
		$storymanager = DjakaWeb::StoryManager->new({'path' => $params{'stories_path'}, 'story' => $game->mission_id()});
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
	$params{'StoryManager'} = $storymanager;
	my %flags;
	$flags{'nodanger'} = 0;
	$flags{'notell'} = 0;
	$params{'flags'} = \%flags;
	return $class->$orig(%params);
};

#static method
sub get_active_game
{
	my $user = shift;
	return schema->resultset('Game')->get_active_game($user);
}
sub get_game_from_ongoing
{
	my $ongoing = shift;
	my $stories_path = shift;
	my $OA = schema->resultset('OngoingAction')->find($ongoing);
	if(! $OA)
	{
		return (undef, undef);
	}
	my $game = DjakaWeb::Elements::Game->new({'id' => $OA->game_id, 'stories_path' => $stories_path});
	return ($game, $OA);
}

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
sub get_element_name
{
	my $self = shift;
	my $id = shift;
	return $self->StoryManager()->getAttribute($id, 'name');
}
sub get_element_description
{
	my $self = shift;
	my $id = shift;
	my $el = $self->StatusDB()->find({'game_id' => $self->id(), 'object_code' => $id});
    return $self->StoryManager()->getElementDescription($id, $el->{'status'});
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
		my $el_name = $self->StoryManager()->getAttribute($el, 'name');
		my $el_type = $self->StoryManager()->getAttribute($el, 'type');
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
	my $filter = shift; #Exclude actions that only give informations or raise danger (only for test purpose
	my $status = $self->get_status()->get_status($element);
	if($status eq "NOT_FOUND")
	{
		return undef;
	}
	elsif($status eq "NULL")
	{
		$status = 'ANY';
	}
	my %actions = $self->StoryManager()->getActions($element, $status);
	if(! $filter)
	{
        my @already = $self->ActionsDB()->already_used_actions($self->id(), $element);
        for(@already)
        {
            my $a = $_;
            if($actions{$a->action()} && $a->object_status && $actions{$a->action()}->{'real status'} eq $a->object_status)
            {
                delete $actions{$a->action()};
            }
        }
        return %actions;
	}
	else
	{
		my %eff_actions;
		for(keys %actions)
		{
			my $useful = 0;
			for(@{$actions{$_}->{'effects'}})
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
sub do_action
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
		%actions = $self->StoryManager()->getActions($element, $status);
	}
	elsif($author =~ /machine/)
	{
		%actions = $self->StoryManager()->getM2MActions($element, $status);
	}
	if(! ref $actions{$action})
	{
		return;
	}
	my $effects = $actions{$action}->{'effects'};
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
					my $story = $self->StoryManager()->getElementStory($element, $eff[1]);
					my $AA = $self->ActionsDB->get_active_action($self->id());
					$self->StoryDB()->write_story($self->id(), $story, $AA, $self->get_element_name($AA->object_code()), $AA->id());
				}
			}
		}	
		elsif($eff[0] =~ /^DO$/)
		{
			$self->do_action($eff[2], $eff[1], 'machine');
		}
		elsif($eff[0] =~ /^DANGER$/)
		{
			if(! ($self->flags()->{'nodanger'}))
			{
				$self->modify_danger($eff[1]);		
				if(! ($self->flags()->{'notell'}))
				{
					my $story = $self->StoryManager()->getDangerStory($eff[1]);
					my $AA = $self->ActionsDB->get_active_action($self->id());
					$self->StoryDB()->write_story($self->id(), $story, $AA, $self->get_element_name($AA->object_code()), $AA->id());
				}
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
    my $status = $self->get_status()->get_status($element);
    my %actions = $self->StoryManager()->getActions($element, $status);
	$self->ActionsDB->add_action($self->id(), $element, $action, $actions{$action}->{'real status'});
}
#Retrieve the action
sub get_active_action
{
	my $self = shift;
	my $AA = $self->ActionsDB->get_active_action($self->id());
	return $self->get_action_data($AA);
}
sub get_action_data
{
	my $self = shift;
	my $AA = shift;
	if($AA)
	{
		return { id => $AA->id(),
                 object_code => $AA->object_code,
			     object => $self->StoryManager()->getAttribute($AA->object_code, 'name'),
				 action => $AA->action(),
				 clicks => $AA->clicks()}	
	}
	else
	{
		return { id => -1,
                 object_code => -1,
			     object => 'NONE',
			     action => 'NONE',
			     clicks => 0}
	}
}
sub do_active_action
{
	my $self = shift;
	my $AA = $self->ActionsDB->get_active_action($self->id());
	if($AA)
	{
		$self->do_action($AA->object_code, $AA->action(), 'human');
		$AA->active(0);
		$AA->update();
	}
}

sub click
{
	my $self = shift;
	my $limits = shift;
	my $AA = $self->get_active_action();
	return -1 if($AA->{'id'} == -1);
	my $limit = $limits->{$AA->{'action'}};
	my $clicks = $self->ActionsDB->click($self->id());
	if($clicks == $limit)
	{
		$self->do_active_action;
		return 1;
	}
	else
	{
		return 0;
	}
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
	my $victories = $self->StoryManager()->getVictory();	
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
sub get_stories
{
    my $stories_path = shift;
    my $storymanager = DjakaWeb::StoryManager->new({'path' => $stories_path, 'story' => undef});
    return $storymanager->allowed_stories();
}

1;
