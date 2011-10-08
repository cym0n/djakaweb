package DjakaWeb::DjakartaDB::Result::Story;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Djakarta::DjakartaDB::Result::Story

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
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-09-24 00:57:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nO+2DV0NiYKn5c7amqVcYw


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::Story::ResultSet');

package DjakaWeb::DjakartaDB::Story::ResultSet;
use base 'DBIx::Class::ResultSet';

sub writeStory
{
	my $self = shift;
	my $game = shift;
	my $text = shift;
	#DB Dependent query!
	$self->create({ game_id => $game, content => $text, timestamp => \'datetime(\'now\',\'localtime\')' });
}

sub getAllStory
{
	my $self = shift;
	my $game = shift;
	my @story = $self->search({game_id => $game}, {order_by => { -asc => 'timestamp' }});
	my $global = "";
	for(@story)
	{
		$global .= $_->content();
		$global .= "-----\n";
	}
	return $global;
}











1;
