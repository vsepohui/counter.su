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
	$r->get('/counter')->to('Counter#counter');
	
	$self->helper(
		'html_escape' => sub {
			my $self = shift;
			my $str  = shift;
			
			$str =~ s/&/&amp;/g;   # Ampersand must be first
			$str =~ s/</&lt;/g;    # Less than
			$str =~ s/>/&gt;/g;    # Greater than
			$str =~ s/"/&quot;/g;  # Double quote
			$str =~ s/'/&#39;/g;   # Single quote

			return $str;
		},
	);	
}

1;
