package YAML::Bind;
use strict;
use YAML::Base -base;

sub init {
    my $self = shift;
    eval "use " . $self->implementation;
}

sub dump {
    my $self = shift;
    no strict 'refs';
    return &{$self->implementation . "::Dump"}(@_);
}


1;
