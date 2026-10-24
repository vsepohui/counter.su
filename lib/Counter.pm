package Counter;

use 5.022;
use warnings;

use Mojo::Base 'Mojolicious';


sub startup {
	my $self = shift;

	my $config = $self->plugin('NotYAMLConfig');

	$self->secrets($config->{secrets});
	my $r = $self->routes;

	$r->get('/')->to('Counter#main');
}

1;
