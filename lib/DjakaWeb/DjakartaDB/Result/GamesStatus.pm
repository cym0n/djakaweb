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
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 object_code

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 4

=head2 active

  data_type: 'integer'
  is_nullable: 1

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 suspect

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "game_id",
  {
    data_type      => "integer",
    default_value  => 0,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "object_code",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 4 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "suspect",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("game_id", "object_code");

=head1 RELATIONS

=head2 game

Type: belongs_to

Related object: L<DjakaWeb::DjakartaDB::Result::Game>

=cut

__PACKAGE__->belongs_to(
  "game",
  "DjakaWeb::DjakartaDB::Result::Game",
  { id => "game_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2013-01-18 00:21:12
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0PkpdTXjo6VBqv+8BDHG9Q


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
	return @out;
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
sub get_suspect
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
		return $els[0]->suspect();
	}
}
sub raise_suspect
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
		if($els[0]->suspect() < 2)
        {
            $els[0]->update({suspect => $els[0]->suspect() + 1});
        }
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
sub snapshot
{
	my $self = shift;
	my $game = shift;
	my @els = $self->search({ game_id => $game});
	return @els;
}
sub overwrite
{
	my $self = shift;
	my $game = shift;
	my $elements = shift;
	my $danger;
	$self->search({ game_id => $game })->delete;
	for(@{$elements})
	{
		my $el = $_;
		if(! ($el->object_code() =~ m/DANGER/))
		{
			$self->create({ game_id => $game, 
					    	          object_code => $el->object_code(), 
							          active => $el->active(),
							          status => $el->status()  
						            });
		}
		else
		{
			$danger = $el->status();
		}
	}
	return $danger;
}




1;
