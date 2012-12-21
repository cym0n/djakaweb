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
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
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
  { data_type => "integer", is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
  "mission_id",
  { data_type => "varchar", is_nullable => 1, size => 3 },
  "danger",
  { data_type => "integer", is_nullable => 1 },
  "active",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-10-14 23:40:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GCJsKE438ub+BSUracZn2g


# You can replace this text with custom code or comments, and it will be preserved on regeneration

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
	my $danger = shift;
	my $game = $self->create({ user_id => $user, mission_id => $mission, danger => $danger, active => 1 });
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
