package Counter::Redis;

use 5.022;
use warnings;

use utf8;
use Redis;


sub new {
	my $class = shift;
	my $self  = {};
	return bless $self, $class;
}

sub redis {
	state $redis = Redis->new(server => '127.0.0.1:6379', encoding => undef);
	return $redis;
}

sub prefix {
	my $self = shift;
	return 'counter';
}

sub build_key {
	my $self = shift;
	my $alias = shift;
	my @key = ($self->prefix);
	push @key, ref $alias ?  @$alias : $alias;
	
	return join '::', @key;
}

sub get {
	my $self = shift;
	my $key = $self->build_key(shift);
	return $self->redis->get($key);
}

sub set {
	my $self = shift;
	my $key = $self->build_key(shift);
	my $val = shift;
	return $self->redis->set($key => $val);
}

sub incr {
	my $self = shift;
	my $key = $self->build_key(shift);
	return $self->redis->incr($key);
}

sub hget {
	my $self = shift;
	my $key = $self->build_key(shift);
	my $field = shift;
	return $self->redis->hget($key, $field);
}

sub hset {
	my $self = shift;
	my $key = $self->build_key(shift);
	my $field = shift;
	my $val = shift;
	return $self->redis->hset($key, $field, $val);
}

sub hkeys {
	my $self = shift;
	my $key = $self->build_key(shift);
	return $self->redis->hkeys($key);
}



1;
