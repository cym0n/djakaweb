package DjakaWeb::DjakartaDB::Result::GamesStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

DjakaWeb::DjakartaDB::Result::GamesStatus

=cut

__PACKAGE__->table("GAMES_STATUS");

=head1 ACCESSORS

=head2 game_id

  data_type: 'integer'
  is_nullable: 0

=head2 object_code

  data_type: 'varchar'
  is_nullable: 0
  size: 4

=head2 active

  data_type: 'integer'
  is_nullable: 1

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "game_id",
  { data_type => "integer", is_nullable => 0 },
  "object_code",
  { data_type => "varchar", is_nullable => 0, size => 4 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);
__PACKAGE__->set_primary_key("game_id", "object_code");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-10-18 00:07:09
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bnu+fGT1So+qtfZbR4KZJg


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::GamesStatus::ResultSet');

package DjakaWeb::DjakartaDB::GamesStatus::ResultSet;
use base 'DBIx::Class::ResultSet';

sub active_only
{
	my $self = shift;
	my @out;
	my @els = $self->search({active => 1});
	for(@els)
	{
		push @out, $_->object_code();
	}
	return \@out;
}

sub init
{
	my $self = shift;
	my $game = shift;
	my $elements = shift;
	for(@{$elements})
	{
		my $el = $_;
		$self->create({ game_id => $game, 
				        object_code => $el, 
						active => 1  
					});
	}
}


sub get_status
{
	my $self = shift;
	my $element = shift;
	my @els = $self->search({ object_code => $element});
	if($#els == -1)
	{
		return "NOT_FOUND";
	}
	else
	{

		return $els[0]->status() ? $els[0]->status() : "NULL";
	}
}
sub get_active
{
	my $self = shift;
	my $element = shift;
	my @els = $self->search({object_code => $element});
	if($#els == -1)
	{
		return 0;
	}
	else
	{
		return $els[0]->active();
	}
}

sub tag
{
	my $self = shift;
	my $game = shift; #Needed to create new elements
	my $element = shift;
	my $tag = shift;
	my @els = $self->search({object_code => $element});
	if($#els == -1)
	{
		$self->create({ game_id => $game, 
				        object_code => $element, 
						active => 0,
					  	status => $tag	
					  });
	}
	else
	{
		$els[0]->update({status => $tag});
	}
}
sub add
{
	my $self = shift;
	my $game = shift;
	my $element = shift;
	my @els = $self->search({object_code => $element});
	if($#els == -1)
	{
		$self->create({ game_id => $game, 
					    object_code => $element, 
						active => 1  
					});
	}
	else
	{
		$els[0]->update({active => 1});
	}
}
sub remove
{
	my $self = shift;
	my $game = shift;
	my $element = shift;
	my @els = $self->search({object_code => $element});
	if($#els == -1)
	{
	}
	else
	{
		$els[0]->update({active => 0});
	}
}

sub print_status
{
	my $self = shift;
	my @els = $self->all();
	for(@els)
	{
		my $status = $_->status() ? $_->status() : "NULL";
		print $_->object_code() . " " . $_->object_type() . " " . $_->active() . " " . $status  . "\n";
	}
}



1;
