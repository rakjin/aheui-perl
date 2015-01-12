package Acme::Aheui::Machine;
use Moose;
use namespace::autoclean;

has 'source' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);


__PACKAGE__->meta->make_immutable;
1;