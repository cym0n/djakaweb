package DjakaWeb::DjakartaDB::Result::Click;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

DjakaWeb::DjakartaDB::Result::Click

=cut

__PACKAGE__->table("CLICKS");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 action

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 15

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "action",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 15 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
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

=head2 action

Type: belongs_to

Related object: L<DjakaWeb::DjakartaDB::Result::OngoingAction>

=cut

__PACKAGE__->belongs_to(
  "action",
  "DjakaWeb::DjakartaDB::Result::OngoingAction",
  { id => "action" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-12-29 21:30:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vY0PP2Wkz7Hi0quRhs6WeQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

#Changes to the table to make timestamp works
__PACKAGE__->load_components("TimeStamp");
__PACKAGE__->remove_column("timestamp");
__PACKAGE__->add_column(  "timestamp", { data_type => "datetime", is_nullable => 0, set_on_create => 1 });

1;
