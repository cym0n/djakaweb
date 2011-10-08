package DjakaWeb::DjakartaDB::Result::GamesStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Djakarta::DjakartaDB::Result::GamesStatus

=cut

__PACKAGE__->table("GAMES_STATUS");

=head1 ACCESSORS

=head2 game_id

  data_type: 'integer'
  is_nullable: 0

=head2 object_code

  data_type: 'varchar'
  is_nullable: 0
  size: 4

=head2 object_type

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 active

  data_type: 'integer'
  is_nullable: 1

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "game_id",
  { data_type => "integer", is_nullable => 0 },
  "object_code",
  { data_type => "varchar", is_nullable => 0, size => 4 },
  "object_type",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);
__PACKAGE__->set_primary_key("game_id", "object_code");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-09-24 14:11:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xH6KlPuS+qVZkpJpxNOW1w


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::GamesStatus::ResultSet');

package DjakaWeb::DjakartaDB::GamesStatus::ResultSet;
use base 'DBIx::Class::ResultSet';

sub initGame
{
	my $self = shift;
	my $game = shift;
	my $mission = shift;
	my $elements = shift;
	for(@{$elements})
	{
		my $el = $_;
		my $type = DjakaWeb::StoryManager::getAttribute($mission, $el, 'type');
		$self->create({ game_id => $game, 
				        object_code => $el, 
						object_type => $type,
						active => 1  
					});
	}
}

sub getElements
{
	my $self = shift;
	my $game = shift;
	my $category = shift;
	my @out;
	my @els = $self->search({ game_id => $game, object_type => $category, active => 1});
	for(@els)
	{
		push @out, $_->object_code();
	}
	return \@out;
}

sub getStatus
{
	my $self = shift;
	my $game = shift;
	my $element = shift;
	my @els = $self->search({ game_id => $game, object_code => $element});
	if($#els == -1)
	{
		return undef;
	}
	else
	{
		return $els[0]->status();
	}
}
sub getActive
{
	my $self = shift;
	my $game = shift;
	my $element = shift;
	my @els = $self->search({ game_id => $game, object_code => $element});
	if($#els == -1)
	{
		return 0;
	}
	else
	{
		return $els[0]->active();
	}
}

sub tag
{
	my $self = shift;
	my $game = shift;
	my $mission = shift;
	my $element = shift;
	my $tag = shift;
	my @els = $self->search({ game_id => $game, object_code => $element});
	if($#els == -1)
	{
		my $type = DjakaWeb::StoryManager::getAttribute($mission, $element, 'type');
		$self->create({ game_id => $game, 
				        object_code => $element, 
						object_type => $type,
						active => 0,
					  	status => $tag	
					  });
	}
	else
	{
		$els[0]->update({status => $tag});
	}
}
sub add
{
	my $self = shift;
	my $game = shift;
	my $mission = shift;
	my $element = shift;
	my $type = DjakaWeb::StoryManager::getAttribute($mission, $element, 'type');
	my @els = $self->search({ game_id => $game, object_code => $element});
	if($#els == -1)
	{
		$self->create({ game_id => $game, 
					    object_code => $element, 
						object_type => $type,
						active => 1  
					});
	}
	else
	{
		$els[0]->update({active => 1});
	}
}
sub remove
{
	my $self = shift;
	my $game = shift;
	my $element = shift;
	my @els = $self->search({ game_id => $game, object_code => $element});
	if($#els == -1)
	{
	}
	else
	{
		$els[0]->update({active => 0});
	}
}
sub snapshot
{
	my $self = shift;
	my $game = shift;
	my @els = $self->search({ game_id => $game});
	return @els;
}
sub overwrite
{
	my $self = shift;
	my $game = shift;
	my $elements = shift;
	my $danger;
	$self->search({ game_id => $game })->delete;
	for(@{$elements})
	{
		my $el = $_;
		if(! ($el->object_code() =~ m/DANGER/))
		{
			$self->create({ game_id => $game, 
					    	object_code => $el->object_code(), 
							object_type => $el->object_type(),
							active => $el->active(),
							status => $el->status()  
						});
		}
		else
		{
			$danger = $el->status();
		}
	}
	return $danger;
}

sub printStatus
{
	my $self = shift;
	my $game = shift;
	my @els = $self->search({ game_id => $game});
	for(@els)
	{
		my $status = $_->status() ? $_->status() : "NULL";
		print $_->object_code() . " " . $_->object_type() . " " . $_->active() . " " . $status  . "\n";
	}
}

1;

