package Acme::Aheui::Machine;
use Moose;
use namespace::autoclean;

has 'source' => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);


__PACKAGE__->meta->make_immutable;
no Moose;
1;