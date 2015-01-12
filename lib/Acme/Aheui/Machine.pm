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

__PACKAGE__->meta->make_immutable;
1;