package DjakaWeb::DjakartaDB::Result::OngoingAction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

DjakaWeb::DjakartaDB::Result::OngoingAction

=cut

__PACKAGE__->table("ONGOING_ACTIONS");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 game_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 object_code

  data_type: 'varchar'
  is_nullable: 1
  size: 4

=head2 action

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 active

  data_type: 'integer'
  is_nullable: 1

=head2 clicks_done

  data_type: 'integer'
  is_nullable: 1

=head2 object_status

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "game_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "object_code",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "action",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "clicks_done",
  { data_type => "integer", is_nullable => 1 },
  "object_status",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 clicks

Type: has_many

Related object: L<DjakaWeb::DjakartaDB::Result::Click>

=cut

__PACKAGE__->has_many(
  "clicks",
  "DjakaWeb::DjakartaDB::Result::Click",
  { "foreign.action" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 game

Type: belongs_to

Related object: L<DjakaWeb::DjakartaDB::Result::Game>

=cut

__PACKAGE__->belongs_to(
  "game",
  "DjakaWeb::DjakartaDB::Result::Game",
  { id => "game_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 stories

Type: has_many

Related object: L<DjakaWeb::DjakartaDB::Result::Story>

=cut

__PACKAGE__->has_many(
  "stories",
  "DjakaWeb::DjakartaDB::Result::Story",
  { "foreign.parent_action" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-12-30 11:45:06
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:iI3J9VM/wcItxzlHAdTGhw

sub click
{
	my $self = shift;
	my $new_clicks = $self->clicks_done() + 1;
	$self->update({clicks_done => $new_clicks});
	return $new_clicks;
}

sub to_hash
{
	my $self = shift;
	return { id => $self->id(),
             object_code => $self->object_code,
	         object => $self->game->StoryManager()->getAttribute($self->object_code, 'name'),
			 action => $self->action(),
			 clicks => $self->clicks_done()}	
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::OngoingAction::ResultSet');

package DjakaWeb::DjakartaDB::OngoingAction::ResultSet;
use base 'DBIx::Class::ResultSet';

sub add_action
{
	my $self = shift;
	my $game = shift;
	my $object = shift;
	my $action = shift;
	my $status = shift;
	$self->create({game_id => $game, object_code => $object, object_status => $status, action => $action, active => 1, clicks_done => 0});
}

sub get_active_action
{
	my $self = shift;
	my $game = shift;
	return $self->find({game_id => $game, active => 1});
}
sub null_action
{
    return { id => -1,
                 object_code => -1,
			     object => 'NONE',
			     action => 'NONE',
			     clicks => 0}
}

sub already_used_actions
{
    my $self = shift;
    my $object = shift;
    return $self->search({object_code => $object});
}

sub click
{
	my $self = shift;
	my $game = shift;
	my $action = $self->get_active_action($game);
	return $action->click();

}


1;
