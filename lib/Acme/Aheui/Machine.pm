package Acme::Aheui::Machine;
use Moose;
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

    return [[{}]];
}

__PACKAGE__->meta->make_immutable;
1;