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
  is_nullable: 0

=head2 game_id

  data_type: 'integer'
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

=head2 clicks

  data_type: 'integer'
  is_nullable: 1

=head2 object_status

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "game_id",
  { data_type => "integer", is_nullable => 1 },
  "object_code",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "action",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "clicks",
  { data_type => "integer", is_nullable => 1 },
  "object_status",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-12-16 12:13:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5n/EvM0KxGXR4RC4F602tg

sub click
{
	my $self = shift;
	my $new_clicks = $self->clicks() + 1;
	$self->update({clicks => $new_clicks});
	return $new_clicks;
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
	$self->create({game_id => $game, object_code => $object, object_status => $status, action => $action, active => 1, clicks => 0});
}

sub get_active_action
{
	my $self = shift;
	my $game = shift;
	return $self->find({game_id => $game, active => 1});
}
sub already_used_actions
{
    my $self = shift;
    my $game = shift;
    my $object = shift;
    return $self->search({game_id => $game, object_code => $object});
}

sub click
{
	my $self = shift;
	my $game = shift;
	my $action = $self->get_active_action($game);
	return $action->click();

}


1;
