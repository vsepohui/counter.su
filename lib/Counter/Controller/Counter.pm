package Counter::Controller::Counter;

use 5.022;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

use Counter::Redis;

use Data::Validate::Domain qw(is_domain);
use Data::Validate::IP qw(is_ipv4);


sub ip {
	my $self = shift;
	return $self = $self->tx->remote_address;
}

sub redis {
	state $redis = new Counter::Redis;
	return $redis;
}

sub main {
	my $self = shift;
	
	my $host = $self->param('host');
	if (defined $host) {
		return $self->counter;
	}
}

sub counter {
	my $self = shift;
	my $host = $self->param('host');
	
	$host = 'invalid' unless is_domain($host) || is_ipv4($host);
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon ++; $year += 1900;
	my $date = sprintf("%d-%02d-%02d", $year, $mon, $mday);
	
	my $redis = $self->redis;
	
	my $key = $date .'-' . $host;
	
	my $hits = $redis->get($key . '-hits') // 0;
	$hits ++;
	$redis->incr($key . '-hits');
	
	$redis->hset($key .'-hotsts', $self->ip, 1) unless $redis->hexists($key .'-hotsts', $self->ip);
	
	$redis->hset($date .'-hosts', $host, 1) unless $redis->hexists($date .'-hosts', $host);
	
	
	my $hosts = scalar @{$redis->hkeys($key .'-hotsts')};

	$self->render(
		template 	=> 'counter/counter',
		hits 		=> $hits,
		hosts 		=> $hosts,
	);
}

sub top {
	my $self = shift;
	return $self->redirect_to('/top100');
}

sub top100 {
	my $self = shift;
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon ++; $year += 1900;
	my $date = sprintf("%d-%02d-%02d", $year, $mon, $mday);
	
	my $redis = $self->redis;
	
		
	my @hosts = @{$redis->hkeys($date .'-hosts')};
	
	my %stat;
	
	for (@hosts) {
		my $hits = $redis->get($date . '-' . $_ . '-hits') // 0;
		my $hosts = scalar @{$redis->hkeys($date .'-' .$_ .'-hotsts')};
		$stat{$_} = {
			hits 	=> $hits,
			hosts 	=> $hosts,
		};
	}
	
	my @top = sort {$stat{$b}->{hosts} <=> $stat{$a}->{hosts} || $stat{$b}->{hits} <=> $stat{$a}->{hits} || $a cmp $b} keys %stat;
	
		
	$self->render(
		format => 'txt',
		stat 	=> \%stat,
		top 	=> \@top,
	);
}

1;
