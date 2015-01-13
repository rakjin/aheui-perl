package Acme::Aheui::Machine;
use utf8;
use Moose;
use Term::ReadKey;
use Encode qw/encode/;
use namespace::autoclean;

=head1 SYNOPSIS

    use Acme::Aheui::Machine;
    my $machine = Acme::Aheui::Machine->new( source => '아희' );
    $machine->execute();

=head1 DESCRIPTION

아희 인터프리터입니다.
https://aheui.github.io/specification.ko/

javascript 레퍼런스 구현체의 로직을 대부분 차용했습니다.
https://github.com/aheui/jsaheui by Puzzlet Chung

=cut

use constant {
    JONG_STROKE_NUMS =>
        [0, 2, 4, 4, 2, 5, 5, 3, 5, 7, 9, 9, 7, 9,
         9, 8, 4, 4, 6, 2, 4, 1, 3, 4, 3, 4, 4, 3],
    REQUIRED_ELEM_NUMS =>
        [0, 0, 2, 2, 2, 2, 1, 0, 1, 0, 1, 0, 2, 0, 1, 0, 2, 2, 0],
};

=attr source

Line-separated source code of an aheui program to be executed.

=cut

has '_source' => (
    is => 'ro',
    isa => 'Str',
    init_arg => 'source',
    required => 1,
);

has '_codespace' => (
    is => 'rw',
    isa => 'ArrayRef[ArrayRef[HashRef]]',
    init_arg => undef,
);

has '_stacks' => (
    is => 'rw',
    isa => 'ArrayRef[ArrayRef[Int]]',
    init_arg => undef,
    default => sub { [] },
);

has '_stack_index' => (
    is => 'rw',
    isa => 'Int',
    init_arg => undef,
    default => 0,
);

has '_is_stopped' => (
    is => 'rw',
    isa => 'Bool',
    init_arg => undef,
    default => 1,
);


has '_x' => (is => 'rw', isa => 'Int', init_arg => undef, default => 0);
has '_y' => (is => 'rw', isa => 'Int', init_arg => undef, default => 0);
has '_dx' => (is => 'rw', isa => 'Int', init_arg => undef, default => 0);
has '_dy' => (is => 'rw', isa => 'Int', init_arg => undef, default => 0);


=method new

    my $machine = Acme::Aheui::Machine->new( source => '아희' );

This method will create and return Acme::Aheui::Machine object.

=cut

sub BUILD {
    my ($self, $args) = @_;

    $self->_initialize();
}

sub _initialize {
    my ($self) = @_;

    $self->_is_stopped(1);
    $self->_x(0);
    $self->_y(0);
    $self->_dx(0);
    $self->_dy(1);
    $self->_stack_index(0);
    $self->_stacks([]);

    my $codespace = $self->_build_codespace($self->_source);
    $self->_codespace($codespace);
}

sub _build_codespace {
    my ($self, $source) = @_;

    my @lines = split /\r?\n/, $source;
    my @rows = ();
    for my $line (@lines) {
        my @row = ();
        for my $char (split //, $line) {
            my $disassembled = $self->_disassemble_hangul_char($char);
            push @row, $disassembled;
        }
        push @rows, \@row;
    }
    return \@rows;
}

sub _disassemble_hangul_char {
    my ($self, $char) = @_;

    if ($char =~ /[가-힣]/) {
        my $code = unpack 'U', $char;
        $code -= 0xAC00;
        my ($cho, $jung, $jong) = (int($code/28/21), ($code/28)%21, $code%28);
        return {cho => $cho, jung => $jung, jong => $jong};
    }
    else {
        return {cho => -1, jung => -1, jong => -1};
    }
}

=method execute

    $machine->execute();

This method will execute the aheui program.

=cut

sub execute {
    my ($self) = @_;

    $self->_is_stopped(0);
    $self->_step();
}

sub _step {
    my ($self) = @_;

    while (1) {

        if ($self->_is_stopped) {
            last;
        }

        if ($self->_x >= scalar @{$self->_codespace->[$self->_y]}) {
            $self->_move_cursor();
            next;
        }

        my $c = $self->_codespace->[$self->_y]->[$self->_x];

        if (!$c || $c->{cho} == -1) {
            $self->_move_cursor();
            next;
        }

        my $cho = $c->{cho};
        my $jung = $c->{jung};
        my $jong = $c->{jong};
        my $si = $self->_stack_index;

        my ($dx, $dy) = $self->_get_deltas_upon_jung($jung);
        $self->_dx($dx);
        $self->_dy($dy);

        my $stack = $self->_stacks->[$si];
        my $elem_num = ($stack) ? scalar @{$self->_stacks->[$si]} : 0;
        if ($elem_num < REQUIRED_ELEM_NUMS->[$cho]) {
            $self->_dx(-($self->_dx));
            $self->_dy(-($self->_dy));
        }
        else {
            if ($cho == 2) { # ㄴ
                my $a = $self->_pop($si);
                my $b = $self->_pop($si);
                $self->_push($si, int($b/$a));
            }
            elsif ($cho == 3) { # ㄷ
                my $a = $self->_pop($si);
                my $b = $self->_pop($si);
                $self->_push($si, $b+$a);
            }
            elsif ($cho == 16) { # ㅌ
                my $a = $self->_pop($si);
                my $b = $self->_pop($si);
                $self->_push($si, $b-$a);
            }
            elsif ($cho == 4) { # ㄸ
                my $a = $self->_pop($si);
                my $b = $self->_pop($si);
                $self->_push($si, $b*$a);
            }
            elsif ($cho == 5) { # ㄹ
                my $a = $self->_pop($si);
                my $b = $self->_pop($si);
                $self->_push($si, $b%$a);
            }
            elsif ($cho == 6) { # ㅁ
                my $a = $self->_pop($si);
                if ($jong == 21) { # jongㅇ
                    $self->_output_number($a);
                }
                elsif ($jong == 27) { # jongㅎ
                    $self->_output_code_as_character($a);
                }
            }
            elsif ($cho == 7) { # ㅂ
                my $a = 0;
                if ($jong == 21) { # jongㅇ
                    $a = $self->_get_input_number();
                }
                elsif ($jong == 27) { # jongㅎ
                    $a = $self->_get_input_character_as_code();
                }
                else { # the other jongs
                    $a = JONG_STROKE_NUMS->[$jong];
                }
                $self->_push($si, $a);
            }
            elsif ($cho == 8) { # ㅃ
                $self->_duplicate($si);
            }
            elsif ($cho == 17) { # ㅍ
                $self->_swap($si);
            }
            elsif ($cho == 9) { # ㅅ
                $self->_stack_index($jong);
            }
            elsif ($cho == 10) { # ㅆ
                $self->_push($jong, $self->_pop($si));
            }
            elsif ($cho == 12) { # ㅈ
                my $a = $self->_pop($si);
                my $b = $self->_pop($si);
                my $in = ($b >= $a) ? 1 : 0;
                $self->_push($si, $in);
            }
            elsif ($cho == 14) { # ㅊ
                if ($self->_pop($si) == 0) {
                    $self->_dx(-($self->_dx));
                    $self->_dy(-($self->_dy));
                }
            }
            elsif ($cho == 18) { # ㅎ
                $self->_is_stopped(1);
            }
        }

        $self->_move_cursor();
    }
}

sub _move_cursor {
    my ($self) = @_;

    $self->_x($self->_x + $self->_dx);
    $self->_y($self->_y + $self->_dy);

    if ($self->_y < 0) {
        $self->_y(scalar @{$self->_codespace} - 1);
    }
    if ($self->_y >= scalar @{$self->_codespace}) {
        $self->_y(0);
    }

    if ($self->_x < 0) {
        $self->_x(scalar @{$self->_codespace->[$self->_y]} - 1);
    }
    if ($self->_x >= scalar @{$self->_codespace->[$self->_y]} &&
        $self->_dx != 0) {
        $self->_x(0);
    }
}

sub _get_deltas_upon_jung {
    my ($self, $jung) = @_;

    my $dx = $self->_dx;
    my $dy = $self->_dy;

    if ($jung == 0) {
        return (1, 0); # ㅏ
    }
    elsif ($jung == 2) {
        return (2, 0); # ㅑ
    }
    elsif ($jung == 4) {
        return (-1, 0); # ㅓ
    }
    elsif ($jung == 6) {
        return (-2, 0); # ㅕ
    }
    elsif ($jung == 8) {
        return (0, -1); # ㅗ
    }
    elsif ($jung == 12) {
        return (0, -2); # ㅛ
    }
    elsif ($jung == 13) {
        return (0, 1); # ㅜ
    }
    elsif ($jung == 17) {
        return (0, 2); # ㅠ
    }
    elsif ($jung == 18) {
        return ($dx, -$dy); # ㅡ
    }
    elsif ($jung == 19) {
        return (-$dx, -$dy); # ㅢ
    }
    elsif ($jung == 20) {
        return (-$dx, $dy); # ㅣ
    }
    else {
        return ($dx, $dy);
    }
}

sub _push {
    my ($self, $i, $n) = @_;

    if ($i == 27) { # ㅎ
        return;
    }
    else {
        push @{$self->_stacks->[$i]}, $n;
    }
}

sub _pop {
    my ($self, $i) = @_;
    my $stack = $self->_stacks->[$i];

    if ($i == 21) { # ㅇ
        return shift @$stack;
    }
    elsif ($i == 27) { # ㅎ
        return;
    }
    else {
        return pop @$stack;
    }
}

sub _duplicate {
    my ($self, $i) = @_;
    my $stack = $self->_stacks->[$i];

    if ($i == 21) { # ㅇ
        my $first = $$stack[0];
        unshift @$stack, $first;
    }
    elsif ($i == 27) { # ㅎ
        return;
    }
    else {
        my $last = $$stack[-1];
        push @$stack, $last;
    }
}

sub _swap {
    my ($self, $i) = @_;
    my $stack = $self->_stacks->[$i];

    if ($i == 21) { # ㅇ
        my $first = $$stack[0];
        my $second = $$stack[1];
        $$stack[0] = $second;
        $$stack[1] = $first;
    }
    elsif ($i == 27) { # ㅎ
        return;
    }
    else {
        my $last = $$stack[-1];
        my $next = $$stack[-2];
        $$stack[-1] = $next;
        $$stack[-2] = $last;
    }
}

sub _output_number {
    my ($self, $number) = @_;

    print $number;
}

sub _output_code_as_character {
    my ($self, $code) = @_;

    my $unichar = pack 'U', $code;
    print encode('utf-8', $unichar);
}

sub _get_input_character_as_code {
    my ($self) = @_;

    my $char = ReadKey(0);
    return unpack 'U', $char;
}

sub _get_input_number {
    my ($self) = @_;

    return int(ReadLine(0));
}

__PACKAGE__->meta->make_immutable;
1;