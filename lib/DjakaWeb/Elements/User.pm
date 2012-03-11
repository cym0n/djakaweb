package DjakaWeb::Elements::User;

use Dancer;
use Moose;
use Dancer::Plugin::DBIC;
use DateTime;

has 'id' => (
	is 		 => 'ro',
);
has 'UserDB' => (
	is       => 'ro',
);
has 'facebook_id' => (
	is 		 => 'ro',
);

my $meta = __PACKAGE__->meta;
my $schema = schema;

around BUILDARGS => sub {
	my $orig  = shift;
    my $class = shift;
	my $params_ref = shift;
	my %params = %{$params_ref};
	if($params{'facebook_id'})
	{
		my $user = $schema->resultset('User')->find({'facebook_id' => $params{'facebook_id'}});
		if(! $user)
		{
			my $new_user = $schema->resultset('User')->newUser($params{'facebook_id'});
			$params{'id'} = $new_user->id();
			$params{'UserDB'} = $new_user;
		}
		else
		{
			$params{'id'} = $user->id();
			$params{'UserDB'} = $user;
		}
		return $class->$orig(%params);
	}	
	elsif($params{'id'})
	{
		my $user = $schema->resultset('User')->find($params{'id'});
		$params{'UserDB'} = $user;
		$params{'facebook_id'} = $user->facebook_id();
		return $class->$orig(%params);
	}
};

sub last_action_done
{
	my $self = shift;
	return $self->UserDB()->last_action_done();
}

sub update_click_time
{
	my $self = shift;	
	return $self->UserDB()->update_click_time();
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
	debug $now;
	my $now_e = $now->epoch();
	my $duration = $next_e - $now_e;
	debug "$timestamp_e $now_e $next_e $duration";
	return $duration;
}

1;

