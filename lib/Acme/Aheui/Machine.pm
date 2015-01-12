package Acme::Aheui::Machine;
use utf8;
use Moose;
use Data::Dumper;
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
            my %code = ('raw' => $char);
            push @row, \%code;
        }
        push @rows, \@row;
    }
    return \@rows;
}

__PACKAGE__->meta->make_immutable;
1;