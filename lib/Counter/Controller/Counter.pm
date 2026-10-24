package Counter::Controller::Counter;

use 5.022;
use warnings;

use Mojo::Base 'Mojolicious::Controller';


sub main {
	my $self = shift;
	$self->render(msg => 'COUNTER.SU!');
}

1;
