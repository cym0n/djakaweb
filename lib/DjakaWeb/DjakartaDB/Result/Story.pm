package DjakaWeb::DjakartaDB::Result::Story;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

DjakaWeb::DjakartaDB::Result::Story

=cut

__PACKAGE__->table("STORIES");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 game_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 object_code

  data_type: 'varchar'
  is_nullable: 1
  size: 4

=head2 action

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 object_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 parent_action

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "game_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "object_code",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "action",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "object_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "parent_action",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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

=head2 parent_action

Type: belongs_to

Related object: L<DjakaWeb::DjakartaDB::Result::OngoingAction>

=cut

__PACKAGE__->belongs_to(
  "parent_action",
  "DjakaWeb::DjakartaDB::Result::OngoingAction",
  { id => "parent_action" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-12-29 21:30:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tP4x42fuXLa+qchun1bquQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

#Changes to the table to make timestamp works
__PACKAGE__->load_components("TimeStamp");
__PACKAGE__->remove_column("timestamp");
__PACKAGE__->add_column(  "timestamp", { data_type => "datetime", is_nullable => 0, set_on_create => 1 });

__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::Story::ResultSet');
package DjakaWeb::DjakartaDB::Story::ResultSet;
use base 'DBIx::Class::ResultSet';

sub write_story
{
	my $self = shift;
	my $game = shift;
	my $text = shift;
	my $action = shift;
	my $object_name = shift;
	my $parent_action = shift;
	if($action)
	{
		$self->create({ game_id => $game, content => $text, action => $action->action(), object_code => $action->object_code(), object_name => $object_name, parent_action => $parent_action });
	}
	else
	{
		$self->create({ game_id => $game, content => $text, action => undef, object_code => undef, object_name => undef, parent_action => undef });
	}
}

sub get_all_story
{
	my $self = shift;
	my $order = shift;
	my @story = $self->search(undef, {order_by => { -$order => 'timestamp' }});
	return \@story;
}









1;
