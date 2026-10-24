package Counter::Controller::Counter;

use 5.022;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use Counter::Redis;

use Data::Validate::Domain qw(is_domain);
use Data::Validate::IP qw(is_ipv4);


sub main {
	my $self = shift;
	$self->render(msg => 'COUNTER.SU!');
}

sub counter {
	my $self = shift;
	my $host = $self->param('host');
	
	return $self->reply->not_found unless is_domain($host) || is_ipv4($host);
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon ++; $year += 1900;
	my $date = sprintf("%d-%02d-%02d", $year, $mon, $mday);
	
	state $redis = new Counter::Redis;
	
	my $key = $date .'-' . $host;
	
	my $hits = $redis->get($key . '-hits') // 0;
	$hits ++;
	$redis->incr($key . '-hits');
	
	my $hosts = 0;

	$self->render(
		hits => $hits,
		hosts => $hosts,
	);
}

1;
