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

{ # move cursor
    my $source = <<'SOURCE_01';
가나다
라마
바사아자차
카
타파하
SOURCE_01
    
    my $machine = Acme::Aheui::Machine->new( source => $source );
    is( $machine->_x, 0 );
    is( $machine->_y, 0 );
    is( $machine->_dx, 0 );
    is( $machine->_dy, 0 );

    $machine->_dx(1);
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [1, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [0, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [1, 0] );

    $machine->_dx(-1);
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [0, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [1, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [0, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 0] );

    $machine->_dx(0);
    $machine->_dy(1);
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 1] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 2] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 3] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 4] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 1] );

    $machine->_dy(-1);
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 4] );

    $machine->_dx(2);
    $machine->_dy(0);
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [0, 4] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 4] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [0, 4] );

    $machine->_dx(-2);
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 4] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [0, 4] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 4] );

    $machine->_dx(0);
    $machine->_dy(2);
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 2] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 4] );

    $machine->_dy(-2);
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 2] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 0] );
    $machine->_move_cursor();
    is_deeply( [$machine->_x, $machine->_y], [2, 4] );
}

done_testing();
