package Acme::Aheui::Machine;
use utf8;
use Moose;
use Data::Dumper;
use POSIX;
use namespace::autoclean;

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


has '_x' => (is => 'rw', isa => 'Int', init_arg => undef, default => 0);
has '_y' => (is => 'rw', isa => 'Int', init_arg => undef, default => 0);
has '_dx' => (is => 'rw', isa => 'Int', init_arg => undef, default => 0);
has '_dy' => (is => 'rw', isa => 'Int', init_arg => undef, default => 0);

sub BUILD {
    my ($self, $args) = @_;

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

    if ($char =~ /\p{Hangul}/) {
        my $code = unpack 'U', $char;
        $code -= 0xAC00;
        my ($cho, $jung, $jong) = (floor($code/28/21), ($code/28)%21, $code%28);
        return {'cho' => $cho, 'jung' => $jung, 'jong' => $jong};
    }
    else {
        return {'cho' => -1, 'jung' => -1, 'jong' => -1};
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

__PACKAGE__->meta->make_immutable;
1;