#/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN {
	use_ok( 'Acme::Aheui::Machine' );
}

my $machine = Acme::Aheui::Machine->new( source => '희' );
ok( $machine );

done_testing();
