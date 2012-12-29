package DjakaWeb::DjakartaDB::Result::TestGraph;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

DjakaWeb::DjakartaDB::Result::TestGraph

=cut

__PACKAGE__->table("TEST_GRAPH");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 start

  data_type: 'integer'
  is_nullable: 1

=head2 element

  data_type: 'varchar'
  is_nullable: 1
  size: 4

=head2 action

  data_type: 'varchar'
  is_nullable: 1
  size: 60

=head2 finish

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "start",
  { data_type => "integer", is_nullable => 1 },
  "element",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "action",
  { data_type => "varchar", is_nullable => 1, size => 60 },
  "finish",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-12-29 21:30:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YpSg5fTxROS5jEZEx6zEdw

sub print
{
    my $self = shift;
    print $self->start() . " --- " . $self->action() . " " . $self->element() . " ---> " . $self->finish() . "\n";
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::TestGraph::ResultSet');

package DjakaWeb::DjakartaDB::TestGraph::ResultSet;
use base 'DBIx::Class::ResultSet';

sub writeArc
{
	my $self = shift;
	my $start = shift;
	my $element = shift;
	my $action  = shift;
	my $arrive = shift;
	$self->create({ start => $start, 
					element => $element, 
				    action => $action,
					finish => $arrive,
					});
}



1;
