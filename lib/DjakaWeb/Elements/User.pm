package DjakaWeb::Elements::User;

use Dancer;
use Moose;
use Dancer::Plugin::DBIC;

has 'id' => (
	is 		 => 'ro',
);
has 'last_action_done' => (
	is       => 'rw',
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
		return $class->$orig(%params);
	}	
	else
	{
		my $user = $schema->resultset('User')->find($params{'id'});
		$params{'last_action_done'} = $game->last_action_done();
		return $class->$orig(%params);
	}
};
