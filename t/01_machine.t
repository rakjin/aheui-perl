#/usr/bin/env perl
use utf8;
use strict;
use warnings;
use Test::More;

BEGIN {
	use_ok( 'Acme::Aheui::Machine' );
}

my $source = "우A\r\n희B";
my $machine = Acme::Aheui::Machine->new( source => $source );
ok( $machine );
is( ${$machine->_codespace}[0][0]{'raw'}, '우' );
is( ${$machine->_codespace}[0][1]{'raw'}, 'A' );
is( ${$machine->_codespace}[1][0]{'raw'}, '희' );
is( ${$machine->_codespace}[1][1]{'raw'}, 'B' );

done_testing();
