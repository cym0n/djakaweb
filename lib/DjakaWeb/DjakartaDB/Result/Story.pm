package DjakaWeb::DjakartaDB::Result::Story;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 NAME

DjakaWeb::DjakartaDB::Result::Story

=cut

__PACKAGE__->table("STORIES");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 game_id

  data_type: 'integer'
  is_nullable: 1

=head2 content

  data_type: 'text'
  is_nullable: 1

=head2 timestamp

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "game_id",
  { data_type => "integer", is_nullable => 1 },
  "content",
  { data_type => "text", is_nullable => 1 },
  "timestamp",
  { data_type => "datetime", is_nullable => 0, set_on_create => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-03-09 23:49:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:SfPJ2oU+UyywpdAZ/PXOrA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::Story::ResultSet');

package DjakaWeb::DjakartaDB::Story::ResultSet;
use base 'DBIx::Class::ResultSet';

sub write_story
{
	my $self = shift;
	my $game = shift;
	my $text = shift;
	#DB Dependent query!
	$self->create({ game_id => $game, content => $text });
}

sub get_all_story
{
	my $self = shift;
	my $order = shift;
	my @story = $self->search(undef, {order_by => { -$order => 'timestamp' }});
	return \@story;
}









1;
