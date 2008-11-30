package YAML2::Base;
use strict;
use warnings;

sub import {
    my ($class, $flag) = @_;
    my ($package, $module) = caller(0);

    if ($class->isa(__PACKAGE__) and
        defined $flag and
        $flag eq '-base'
    ) {
        $class->import_base($package, $module);
    }
    else {
        require Exporter;
        goto &Exporter::import;
    }
}

sub import_base {
    my ($class, $package, $module) = @_;
    no strict 'refs';
    push @{$package . '::ISA'}, $class;
    $class->import_fake($package, $module);
    $class->export_base($package);
}

sub import_fake {
    my ($class, $package, $module) = @_;
    my $inc_module = $package . '.pm';
    $inc_module =~ s/::/\//g;
    return if defined $INC{$inc_module};
    $INC{$inc_module} = $module;
}

sub export_base {
    my ($source, $target) = @_;
    no strict 'refs';
    for my $sub (map {
        /::/ ? $_ : "${source}::$_"
    } $source->EXPORT_BASE()) {
        my $name = $sub;
        $name =~ s/.*:://;
        *{$target . "::$name"} = \&$sub;
    }
}

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->init(@_);
    return $self;
}

sub dump_object {
    my $class = shift;
    my $args = '(';
    while (my ($k, $v) = splice(@_, 0, 2)) {
        last unless $k;
        if (not defined $v) {
            $v = '~';
        }
        elsif (ref $v) {
            $v = '@';
        }
        elsif (length $v > 15) {
            $v = substr $v, 0, 15;
        }
        $args .= "${k}:$v,";
    }
    $args =~ s/,$//;
    $args .= ')';
#     printf "\t\t\t\t\t\t\t%s :\n%26s %s\n", (caller(2))[3], $class, $args;
    printf "%26s %s\n", $class, $args;
}

sub init {
    my $self = shift;
    while (my ($property, $value) = splice(@_, 0, 2)) {
        unless ($self->can($property)) {
            my $class = ref $self;
            Carp::confess("Class '$class' has no property '$property'");
        }
        $self->$property($value);
    }
}

sub create {
    my $self = shift;
    my $object_class = (shift) . '_class';
    my $module_name = $self->$object_class;
    eval "require $module_name";
    $self->die("Error in require $module_name - $@")
        if $@ and "$@" !~ /Can't locate/;
    return $module_name->new;
}

sub die {
    my $self = shift;
    Carp::confess(@_);
}

my %code = (
    sub_start =>
      "sub {\n",
    set_default =>
      "  \$_[0]->{%s} = %s\n    unless exists \$_[0]->{%s};\n",
    class =>
      "  return do { my \$class = \$_[0]; %s } unless ref \$_[0];\n",
    init =>
      "  return \$_[0]->{%s} = do { my \$self = \$_[0]; %s }\n" .
      "    unless \$#_ > 0 or defined \$_[0]->{%s};\n",
    return_if_get =>
      "  return \$_[0]->{%s} unless \$#_ > 0;\n",
    set =>
      "  \$_[0]->{%s} = \$_[1];\n",
    onset =>
      "  do { local \$_ = \$_[1]; my \$self = \$_[0]; %s };\n",
    chain =>
      "  return \$_[0];\n}\n",
    sub_end => 
      "  return \$_[0]->{%s};\n}\n",
);

my $parse_arguments = sub {
    my $paired_arguments = shift || []; 
    my ($args, @values) = ({}, ());
    my %pairs = map { ($_, 1) } @$paired_arguments;
    while (@_) {
        my $elem = shift;
        if (defined $elem and defined $pairs{$elem} and @_) {
            $args->{$elem} = shift;
        }
        elsif ($elem eq '-chain') {
            $args->{-chain} = 1;
        }
        else {
            push @values, $elem;
        }
    }
    return wantarray ? ($args, @values) : $args;        
};

my $default_as_code = sub {
    no warnings 'once';
    require Data::Dumper;
    local $Data::Dumper::Sortkeys = 1;
    my $code = Data::Dumper::Dumper(shift);
    $code =~ s/^\$VAR1 = //;
    $code =~ s/;$//;
    return $code;
};

sub field {
    my $package = caller;
    my ($args, @values) = &$parse_arguments(
        [ qw(-package -class -init -onset) ],
        @_,
    );
    my ($field, $default) = @values;
    $package = $args->{-package} if defined $args->{-package};
    return if defined &{"${package}::$field"};
    my $default_string =
        ( ref($default) eq 'ARRAY' and not @$default )
        ? '[]'
        : (ref($default) eq 'HASH' and not keys %$default )
          ? '{}'
          : &$default_as_code($default);

    my $code = $code{sub_start};

    if ($args->{-class}) {
        if ($args->{-class} eq '-init') {
            $args->{-class} = $args->{-init};
            $args->{-class} =~ s/\$self/\$class/g;
        }
        my $fragment = $code{class};
        $code .= sprintf
            $fragment,
            $args->{-class};
    }

    if ($args->{-init}) {
        my $fragment = $code{init};
        $code .= sprintf
            $fragment,
            $field,
            $args->{-init},
            ($field) x 4;
    }
    $code .= sprintf $code{set_default}, $field, $default_string, $field
      if defined $default;
    $code .= sprintf $code{return_if_get}, $field;
    $code .= sprintf $code{set}, $field;
    $code .= sprintf $code{onset}, $args->{-onset}
      if defined $args->{-onset};
    if (defined $args->{-chain}) {
        $code .= $code{chain};
    }
    else {
        $code .= sprintf $code{sub_end}, $field;
    }

    my $sub = eval $code;
    CORE::die $@ if $@;
    no strict 'refs';
    *{"${package}::$field"} = $sub;
    return $code if defined wantarray;
}

sub _dump {
    no warnings 'once';
    return YAML::XS::Dump(@_);
}

sub XXX {
    CORE::die _dump(@_);
}

sub WWW {
    CORE::warn _dump(@_);
    return(@_);
}

sub assert {
    Carp::confess("assert failed") unless $_[0];
}

sub throw {
    CORE::die @_;
}

sub EXPORT_BASE {
    return qw(
        YAML2::Base::field
        YAML2::Base::XXX
        YAML2::Base::WWW
        YAML2::Base::assert
        YAML2::Base::throw
    );
}

1;

=head1 NAME

YAML2::Base - Base Class of all YAML Components

=head1 SYNOPSIS

    package YAML::Foo;
    use strict;
    use warnings;
    use YAML2::Base -base;

    field 'foo';
    field 'bar' => 'blah';

=head1 DESCRIPTION

The YAML2 toolset is made up of a bunch of modules that are object
oriented. All these modules inherit from YAML2::Base, directly or
eventually.

In the spirit of Spiffyness (but without source filtering or
dependencies) YAML2::Base provides the C<field> accessor generator to all
its subclasses. It also provides XXX for debugging with YAML::XS.

Additionally YAML2::Base provides default C<new> and C<init> class
methods for object construction.

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2008. Ingy döt Net. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
