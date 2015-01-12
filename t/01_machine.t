#/usr/bin/env perl
use utf8;
use strict;
use warnings;
use Test::More;

BEGIN {
	use_ok( 'Acme::Aheui::Machine' );
}

my $source = '희';
my $machine = Acme::Aheui::Machine->new( source => $source );
ok( $machine );

done_testing();
