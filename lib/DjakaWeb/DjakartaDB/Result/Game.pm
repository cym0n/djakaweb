package DjakaWeb::DjakartaDB::Result::Game;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

DjakaWeb::DjakartaDB::Result::Game

=cut

__PACKAGE__->table("GAMES");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 mission_id

  data_type: 'varchar'
  is_nullable: 1
  size: 3

=head2 danger

  data_type: 'integer'
  is_nullable: 1

=head2 active

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "mission_id",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "danger",
  { data_type => "integer", is_nullable => 1 },
  "active",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<DjakaWeb::DjakartaDB::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "DjakaWeb::DjakartaDB::Result::User",
  { id => "user_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 games_statuses

Type: has_many

Related object: L<DjakaWeb::DjakartaDB::Result::GamesStatus>

=cut

__PACKAGE__->has_many(
  "games_statuses",
  "DjakaWeb::DjakartaDB::Result::GamesStatus",
  { "foreign.game_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ongoing_actions

Type: has_many

Related object: L<DjakaWeb::DjakartaDB::Result::OngoingAction>

=cut

__PACKAGE__->has_many(
  "ongoing_actions",
  "DjakaWeb::DjakartaDB::Result::OngoingAction",
  { "foreign.game_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 stories

Type: has_many

Related object: L<DjakaWeb::DjakartaDB::Result::Story>

=cut

__PACKAGE__->has_many(
  "stories",
  "DjakaWeb::DjakartaDB::Result::Story",
  { "foreign.game_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-12-29 21:30:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Q2EZvqDP4LOeXtCEWUQeng


# You can replace this text with custom code or comments, and it will be preserved on regeneration

use DjakaWeb::StoryManager;


sub StoryManager
{
    my $self = shift;
    return DjakaWeb::StoryManager->new({'story' => $self->mission_id()});
}

sub get_elements
{
	my $self = shift;
	my %out;
	my @els = $self->games_statuses->active_only();
	for(@els)
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
sub get_all_story
{
	my $self = shift;
	return $self->stories->search(undef, {order_by => { -desc => 'timestamp' }});
}
sub get_active_action
{
	my $self = shift;
	my $AA = $self->ongoing_actions->get_active_action();
    if($AA)
    {
	    return $AA->to_hash();
    }
    else
    {
        return $self->ongoing_actions->null_action();
    }
}
sub get_actions
{
	my $self = shift;
	my $element = shift;
	my $filter = shift; #Exclude actions that only give informations or raise danger (only for test purpose
	my $status = $self->games_statuses->get_status($element);
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
        my @already = $self->ongoing_actions->already_used_actions($element);
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
	my $el = $self->games_statuses->find({'object_code' => $id});
    return $self->StoryManager()->getElementDescription($id, $el->{'status'});
}
sub schedule_action
{
	my $self = shift;
	my $element = shift;
	my $action = shift;
    my $status = $self->games_statuses->get_status($element);
    my %actions = $self->StoryManager()->getActions($element, $status);
	$self->ongoing_actions->add_action($self->id(), $element, $action, $actions{$action}->{'real status'});
}
sub click
{
	my $self = shift;
	my $limits = shift;
	my $AA = $self->get_active_action();
	return -1 if($AA->{'id'} == -1);
	my $limit = $limits->{$AA->{'action'}};
	my $clicks = $self->ongoing_actions->get_active_action()->click();
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
sub do_active_action
{
	my $self = shift;
	my $AA = $self->ongoing_actions->get_active_action();
	if($AA)
	{
		$self->do_action($AA->object_code, $AA->action(), 'human');
		$AA->active(0);
		$AA->update();
	}
}
sub do_action
{
	my $self = shift;
	my $element = shift;
	my $action = shift;
	my $author = shift;
	my $status = $self->games_statuses->get_status($element);
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
			$self->games_statuses->tag($self->id, $element, $eff[1]); #Game id needed to create new elements
		}
		elsif($eff[0] =~ /^ADD$/)	
		{
			$self->games_statuses->add($self->id(), $eff[1]);
		}
		elsif($eff[0] =~ /^REMOVE$/)	
		{
			$self->games_statuses->remove($eff[1]);
		}
		elsif($eff[0] =~ /^TELL$/)
		{
            #TODO: manage flags
            #if(! ($self->flags()->{'notell'}))
            #{
				if($self->games_statuses->get_active($element) == 1)
				{
					my $story = $self->StoryManager()->getElementStory($element, $eff[1]);
					my $AA = $self->ongoing_actions->get_active_action();
					$self->stories->write_story($self->id(), $story, $AA, $self->get_element_name($AA->object_code()), $AA->id());
				}
            #}
		}	
		elsif($eff[0] =~ /^DO$/)
		{
			$self->do_action($eff[2], $eff[1], 'machine');
		}
		elsif($eff[0] =~ /^DANGER$/)
		{
            #TODO: manage flags
            #if(! ($self->flags()->{'nodanger'}))
            #{
				$self->modify_danger($eff[1]);		
                #if(! ($self->flags()->{'notell'}))
                #{
					my $story = $self->StoryManager()->getDangerStory($eff[1]);
					my $AA = $self->ongoing_actions->get_active_action();
					$self->stories->write_story($self->id(), $story, $AA, $self->get_element_name($AA->object_code()), $AA->id());
                    #}
            #}
		}
	}
}
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
			my $status = $self->games_statuses->get_status($_);
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
sub get_victory
{
    my $self = shift;
    my $tag = shift;
	my $victories = $self->StoryManager()->getVictory();	
    return %{$victories->{$tag}};
}




#Danger management
sub set_danger
{
	my $self = shift;
	my $danger = shift;
	$self->write_danger($danger);
}

sub modify_danger
{
	my $self = shift;
	my $danger = shift;
	$self->write_danger($self->danger() + $danger);
}
sub write_danger
{
	my $self = shift;
	my $danger = shift;
	$self->update({danger => $danger});	
	return $self->danger();
}

sub defeat
{
    my $self = shift;
    $self->update({active => -1});
}
sub victory
{
    my $self = shift;
    $self->update({active => 2});
}


__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::Game::ResultSet');

package DjakaWeb::DjakartaDB::Game::ResultSet;
use base 'DBIx::Class::ResultSet';


sub init
{
	my $self = shift;
	my $user = shift;
	my $mission = shift;
	my $game = $self->create({ user_id => $user, mission_id => $mission, danger => 0, active => 1 });
  	my $elements = $game->StoryManager()->getStartStatus();
	my $story = $game->StoryManager()->getStory();
	my $start_danger = $game->StoryManager->getStartDanger();
    $game->update({danger => $start_danger});
    $game->games_statuses->init($game->id(), $elements);
	$game->stories->write_story($game->id(), $story);
	return $game;
}

sub get_active_game
{
	my $self = shift;
	my $user = shift;
	my @game = $self->search({ user_id => $user, active => 1 });
	if($#game == -1)
	{
		return undef;
	}
	else
	{
		return $game[0]->id();
	}
}

1;
