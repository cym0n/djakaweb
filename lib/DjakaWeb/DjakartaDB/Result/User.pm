package DjakaWeb::DjakartaDB::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

DjakaWeb::DjakartaDB::Result::User

=cut

__PACKAGE__->table("USERS");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 facebook_id

  data_type: 'integer'
  is_nullable: 1

=head2 last_action_done

  data_type: 'timestamp'
  is_nullable: 1

=head2 last_support_done

  data_type: 'timestamp'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "facebook_id",
  { data_type => "integer", is_nullable => 1 },
  "last_action_done",
  { data_type => "timestamp", is_nullable => 1 },
  "last_support_done",
  { data_type => "timestamp", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-31 22:45:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1ZFqjzgqggh9krXgWIaCCQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->remove_column("last_action_done");
__PACKAGE__->add_column("last_action_done", { data_type => "datetime", is_nullable => 1, timezone => "CET" });
__PACKAGE__->remove_column("last_support_done");
__PACKAGE__->add_column("last_support_done", { data_type => "datetime", is_nullable => 1, timezone => "CET" });


sub update_click_time
{
	my $self = shift;
	$self->update({'last_action_done' => DateTime->now()});
	return $self->last_action_done();
}



__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::User::ResultSet');


package DjakaWeb::DjakartaDB::User::ResultSet;
use base 'DBIx::Class::ResultSet';

sub newUser
{
	my $self = shift;
	my $fb = shift;
	my $user = $self->create({last_action_done => undef, facebook_id => $fb });
	return $user;
}



1;
