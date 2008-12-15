package YAML2::Bind::Perl;
use strict;
use YAML2::Bind -base;

field implementation => 'YAML::Perl';

sub emit {
    my $self = shift;
    require YAML::Perl::Emitter;
    my $emitter = YAML::Perl::Emitter->new();
    $emitter->open();
    $emitter->emit(@_);
    return $emitter->stream->string;
}

sub parse {
    my $self = shift;
    require YAML::Perl::Parser;
    my $parser = YAML::Perl::Parser->new();
    $parser->open(@_);
    return $parser->parse();
}

1;
