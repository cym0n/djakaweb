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
  is_auto_increment: 1
  is_nullable: 0

=head2 facebook_id

  data_type: 'integer'
  is_nullable: 1

=head2 last_action_done

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 last_support_done

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 score

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "facebook_id",
  { data_type => "integer", is_nullable => 1 },
  "last_action_done",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "last_support_done",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "score",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 clicks

Type: has_many

Related object: L<DjakaWeb::DjakartaDB::Result::Click>

=cut

__PACKAGE__->has_many(
  "clicks",
  "DjakaWeb::DjakartaDB::Result::Click",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 games

Type: has_many

Related object: L<DjakaWeb::DjakartaDB::Result::Game>

=cut

__PACKAGE__->has_many(
  "games",
  "DjakaWeb::DjakartaDB::Result::Game",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-12-30 23:18:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QKRW4JaEaiUgp8HFkytA5A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->remove_column("last_action_done");
__PACKAGE__->add_column("last_action_done", { data_type => "datetime", is_nullable => 1, timezone => "CET" });
__PACKAGE__->remove_column("last_support_done");
__PACKAGE__->add_column("last_support_done", { data_type => "datetime", is_nullable => 1, timezone => "CET" });


sub get_active_game
{
    my $self = shift;
    return $self->games->find({'active' => 1});
}


sub update_click_time
{
	my $self = shift;
	$self->update({'last_action_done' => DateTime->now()});
	return $self->last_action_done();
}
sub update_support_click_time
{
	my $self = shift;
	$self->update({'last_support_done' => DateTime->now()});
	return $self->last_support_done();
}
sub add_points
{
    my $self = shift;
    my $points = shift;
    my $actual_points = $self->score();
    $actual_points = 0 if ! $actual_points;
    $self->update({'score' => $points + $actual_points});
    return $self->score();
}
sub get_score
{
    my $self = shift;
    if($self->score())
    {
        return $self->score();
    }
    else
    {
        return 0;
    }
}
sub time_to_click
{
	my $self = shift;
	my $waiting_time = shift;
	my $timestamp = $self->last_action_done();
	return -1 if (! $timestamp);
	my $timestamp_e = $timestamp->epoch();
	my $next_e = $timestamp_e + ($waiting_time * 60);
	my $now = DateTime->now();
	my $now_e = $now->epoch();
	my $duration = $next_e - $now_e;
	return $duration;
}
sub time_to_support_click
{
	my $self = shift;
	my $waiting_time = shift;
	my $timestamp = $self->last_support_done();
	return -1 if (! $timestamp);
	my $timestamp_e = $timestamp->epoch();
	my $next_e = $timestamp_e + ($waiting_time * 60);
	my $now = DateTime->now();
	my $now_e = $now->epoch();
	my $duration = $next_e - $now_e;
	return $duration;
}

sub trace_click
{
	my $self = shift;
	my $action = shift;
	my $type = shift;
	$self->result_source->schema->resultset('Click')->create({"user_id" => $self->id,
		                                "action" => $action,
									    "type" => $type});
}
sub story_completed
{
    my $self = shift;
    my $story_code = shift;
    my @games =  $self->result_source->schema->resultset('Game')->search({"user_id" => $self->id,
                                                  "mission_id" => $story_code,
                                                  "active" => 2});
    if(@games)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}
sub get_story_failures
{
    my $self = shift;
    my $story_code = shift;
    my @games =  $self->result_source->schema->resultset('Game')->search({"user_id" => $self->id,
                                                  "mission_id" => $story_code,
                                                  "active" => -1});
    return scalar(@games);
}



__PACKAGE__->resultset_class('DjakaWeb::DjakartaDB::User::ResultSet');


package DjakaWeb::DjakartaDB::User::ResultSet;
use base 'DBIx::Class::ResultSet';

sub newUser
{
	my $self = shift;
	my $fb = shift;
	my $user = $self->create({last_support_done => undef, last_action_done => undef, facebook_id => $fb, score => 0 });
	return $user;
}



1;
