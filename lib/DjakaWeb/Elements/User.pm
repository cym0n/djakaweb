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

my $meta = __PACKAGE__->meta;
my $schema = schema;

around BUILDARGS => sub {
	my $orig  = shift;
    my $class = shift;
	my $params_ref = shift;
	my %params = %{$params_ref};
	if(! $params{'id'})
	{
		my $new_user = $schema->resultset('User')->newUser();
		$params{'id'} = $new_user->id();
		$params{'UserDB'} = $new_user;
		return $class->$orig(%params);
	}	
	else
	{
		my $user = $schema->resultset('User')->find($params{'id'});
		$params{'UserDB'} = $user;
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

sub allowed_to_click
{
	my $self = shift;
	my $waiting_time = shift;
	my $timestamp = $self->last_action_done();
	my $click_gap = $timestamp ? DateTime->now()->subtract_datetime($timestamp) : undef;
	if(! $click_gap)
	{
		return 1;
	}
	elsif($click_gap->minutes > $waiting_time)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

1;

