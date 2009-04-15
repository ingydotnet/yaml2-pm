package YAML::Bind::Perl;
use strict;
use YAML::Bind -base;

field implementation => 'YAML::Perl';

sub emit {
    my $self = shift;
    require YAML::Perl::Emitter;
    my $emitter = YAML::Perl::Emitter->new();
    $emitter->open();
    $emitter->emit(@_);
    return $emitter->writer->stream->string;
}

sub parse {
    my $self = shift;
    require YAML::Perl::Parser;
    my $parser = YAML::Perl::Parser->new();
    $parser->open(@_);
    return $parser->parse();
}

1;
