#/usr/bin/env perl
use utf8;
use strict;
use warnings;
use Test::More;

BEGIN {
	use_ok( 'Acme::Aheui::Machine' );
}

{ # new machine and its internal codespace
    my $source = "가각\r\n힢힣\nA *";
    my $machine = Acme::Aheui::Machine->new( source => $source );
    ok( $machine );
    is( ${$machine->_codespace}[0][0]{'cho'}, 0 );
    is( ${$machine->_codespace}[0][0]{'jung'}, 0 );
    is( ${$machine->_codespace}[0][0]{'jong'}, 0 );

    is( ${$machine->_codespace}[0][1]{'cho'}, 0 );
    is( ${$machine->_codespace}[0][1]{'jung'}, 0 );
    is( ${$machine->_codespace}[0][1]{'jong'}, 1 );

    is( ${$machine->_codespace}[1][0]{'cho'}, 18 );
    is( ${$machine->_codespace}[1][0]{'jung'}, 20 );
    is( ${$machine->_codespace}[1][0]{'jong'}, 26 );

    is( ${$machine->_codespace}[1][1]{'cho'}, 18 );
    is( ${$machine->_codespace}[1][1]{'jung'}, 20 );
    is( ${$machine->_codespace}[1][1]{'jong'}, 27 );

    is( ${$machine->_codespace}[2][0]{'cho'}, -1 );
    is( ${$machine->_codespace}[2][0]{'jung'}, -1 );
    is( ${$machine->_codespace}[2][0]{'jong'}, -1 );

    is( ${$machine->_codespace}[2][1]{'cho'}, -1 );
    is( ${$machine->_codespace}[2][1]{'jung'}, -1 );
    is( ${$machine->_codespace}[2][1]{'jong'}, -1 );

    is( ${$machine->_codespace}[2][2]{'cho'}, -1 );
    is( ${$machine->_codespace}[2][2]{'jung'}, -1 );
    is( ${$machine->_codespace}[2][2]{'jong'}, -1 );
}

done_testing();
