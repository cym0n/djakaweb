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

sub get_active_action
{
	my $self = shift;
	my $game = shift;
	return $self->find($game)->ongoing_actions->find({active => 1});
}


1;
