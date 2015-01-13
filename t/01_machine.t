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
    my $source = <<'__SOURCE__';
가나다
라마
바사아자차
카
타파하
__SOURCE__
    
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

{ # storages

    my $counter = 0;
    sub test_stack {
        my ($machine, $storage_index) = @_;

        # a push and a pop
        my $in = $counter++;
        $machine->_push($storage_index, $in);
        my $out = $machine->_pop($storage_index);
        is( $in, $out );

        # pushes, pops
        my ($in1, $in2, $in3) = ($counter++, $counter++, $counter++);
        $machine->_push($storage_index, $in1);
        $machine->_push($storage_index, $in2);
        $machine->_push($storage_index, $in3);
        my $out3 = $machine->_pop($storage_index);
        my $out2 = $machine->_pop($storage_index);
        my $out1 = $machine->_pop($storage_index);
        is_deeply( [$in1, $in2, $in3], [$out1, $out2, $out3] );

        # duplicate
        my $first_in = $counter++;
        my $later_in = $counter++;
        $machine->_push($storage_index, $first_in);
        $machine->_push($storage_index, $later_in);
        $machine->_duplicate($storage_index);
        my $out_dup1 = $machine->_pop($storage_index);
        my $out_dup2 = $machine->_pop($storage_index);
        is( $later_in, $out_dup1 );
        is( $later_in, $out_dup2 );
        $machine->_pop($storage_index);

        # swap
        $first_in = $counter++;
        $later_in = $counter++;
        $machine->_push($storage_index, $first_in);
        $machine->_push($storage_index, $later_in);
        $machine->_swap($storage_index);
        my $first_out = $machine->_pop($storage_index);
        my $later_out = $machine->_pop($storage_index);
        is( $first_in, $first_out );
        is( $later_in, $later_out );
    }

    sub test_queue {
        my ($machine, $storage_index) = @_;

        # a push and a pop
        my $in = $counter++;
        $machine->_push($storage_index, $in);
        my $out = $machine->_pop($storage_index);
        is( $in, $out );

        # pushes, pops
        my ($in1, $in2, $in3) = ($counter++, $counter++, $counter++);
        $machine->_push($storage_index, $in1);
        $machine->_push($storage_index, $in2);
        $machine->_push($storage_index, $in3);
        my $out1 = $machine->_pop($storage_index);
        my $out2 = $machine->_pop($storage_index);
        my $out3 = $machine->_pop($storage_index);
        is_deeply( [$in1, $in2, $in3], [$out1, $out2, $out3] );

        # duplicate
        my $first_in = $counter++;
        my $later_in = $counter++;
        $machine->_push($storage_index, $first_in);
        $machine->_push($storage_index, $later_in);
        $machine->_duplicate($storage_index);
        my $out_dup1 = $machine->_pop($storage_index);
        my $out_dup2 = $machine->_pop($storage_index);
        is( $first_in, $out_dup1 );
        is( $first_in, $out_dup2 );
        $machine->_pop($storage_index);

        # swap
        $first_in = $counter++;
        $later_in = $counter++;
        $machine->_push($storage_index, $first_in);
        $machine->_push($storage_index, $later_in);
        $machine->_swap($storage_index);
        my $first_out = $machine->_pop($storage_index);
        my $later_out = $machine->_pop($storage_index);
        is( $first_in, $later_out );
        is( $later_in, $first_out );
    }

    my $machine = Acme::Aheui::Machine->new( source => '' );
    for my $i (0..26) {
        if ($i == 21) { # ㅇ queue
            test_queue($machine, $i);
        }
        else { # '', ㄱ, ㄴ, ... ㅆ, ㅈ, .. ㅍ stack
            test_stack($machine, $i);
        }
    }
}

done_testing();
