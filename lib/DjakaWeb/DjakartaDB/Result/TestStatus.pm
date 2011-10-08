package DjakaWeb::DjakartaDB::Result::TestStatus;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Djakarta::DjakartaDB::Result::TestStatus

=cut

__PACKAGE__->table("TEST_STATUS");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 status_id

  data_type: 'integer'
  is_nullable: 1

=head2 object_code

  data_type: 'varchar'
  is_nullable: 1
  size: 4

=head2 object_type

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 active

  data_type: 'integer'
  is_nullable: 1

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "status_id",
  { data_type => "integer", is_nullable => 1 },
  "object_code",
  { data_type => "varchar", is_nullable => 1, size => 4 },
  "object_type",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-09-27 00:51:02
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TO3tG5/J0ZmaT59GUWmUfQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration

__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::TestStatus::ResultSet');

package DjakaWeb::DjakartaDB::TestStatus::ResultSet;
use base 'DBIx::Class::ResultSet';

sub saveSnapshot
{
	my $self = shift;
	my $status_id = shift;
	my $elements = shift;
	my $danger = shift;
	for(@{$elements})
	{
		my $el = $_;
		$self->create({ status_id => $status_id, 
					    object_code => $el->object_code(), 
						object_type => $el->object_type(),
						active => $el->active(),
						status => $el->status()  
					});
	}
	$self->dangerRow($status_id, $danger);
}
sub dangerRow
{
	my $self = shift;
	my $status_id = shift;
	my $danger_level = shift;
	$self->create({ status_id => $status_id, 
					    object_code => "DANGER", 
						object_type => "reserved",
						active => 1,
						status => $danger_level  
					});
}

sub getSnapshot
{
	my $self = shift;
	my $status_id = shift;
	my @els = $self->search({ status_id => $status_id});
	return @els;
}

sub compareToSnapshot
{
	my $self = shift;
	my $status = shift;
	my $danger = shift;
	my @elements = @{$status};
	my @matching = $self->search({object_code => $elements[0]->object_code(),
								  active => $elements[0]->active(),
								  status => $elements[0]->status()});
	if($#matching == -1)
	{
		return -1;
	}
	else
	{
		for(@matching)
		{
			my $m = $_;
			my @snap =$self->search({status_id => $m->status_id()});
			my %snapshot;
			for(@snap)
			{
				$snapshot{$_->object_code()}{'status'} = $_->status() ? $_->status() : "";
				$snapshot{$_->object_code()}{'active'} = $_->active();
			
			}
			if($#snap == ($#elements+1) && $snapshot{'DANGER'}{'status'} == $danger)
			{
				my $match = 1;
				for(@elements)
				{		
					my $el = $_;
					if($snapshot{$el->object_code()})
					{
						my $elstatus = $el->status() ? $el->status() : "";
						if(! ($snapshot{$el->object_code()}{'status'} eq $elstatus &&
							  $snapshot{$el->object_code()}{'active'} == $el->active()))
					  	{
							$match = 0;
						}	  
					}
				}
				if($match)
				{
					return $m->status_id();
				}
			}
		}
		return -1;
	}
}


1;
