package # hide from pause
YAML;

use 5.005003;
use strict;
use warnings;           # XXX remove this for 5.005003
use YAML::Base -base;

$YAML::VERSION = '0.01';  # !!! Keep $YAML2::VERSION in sync.

@YAML::EXPORT = qw(yaml Dump Load);
@YAML::EXPORT_OK = qw(DumpFile LoadFile freeze thaw);

$YAML::_package_to_implementation = {};
$YAML::_implementation_list = [qw(
    YAML::XS
    YAML::Perl
    YAML::Syck
    YAML::Old
    YAML::Tiny
)];

field implementation => -chain;
field binding =>
    -init => '$self->new_binding_object';

sub croak { require Carp; Carp::croak(@_) }

my $use_package;
sub import {
    my $class = shift;
    $use_package = caller;

    my $implementations;
    ($implementations, @_) = $class->grep_implemntation_list(@_);

    my $implementation = $class->load_implementation($implementations);

    no warnings 'once', 'redefine';
    local (*Dump, *Load, *DumpFile, *LoadFile, *yaml) =
        $class->generate_exportable_subroutines(@_);

    # gather up the possible implementations
    # ask YAML::Any which implementation to use
    # ask YAML::Any for the exportables and localize them
    # localize 'yaml' with proper implementation
    # call Exporter setting $Exporter::ExportLevel = 1

    local $Exporter::ExportLevel = 1;
    &Exporter::import($class, @_);
}

sub get_binding {
    my $package = shift;
    'YAML::Perl';
}

sub new_binding_object {
    my $self = shift;
    require YAML::Bind::Perl;
    return YAML::Bind::Perl->new();
}

{
    no strict 'refs';
    sub Dump { &{get_binding(scalar caller) . "::Dump"}(@_) }
    sub Load { &{get_binding(scalar caller) . "::Load"}(@_) }
    sub DumpFile { &{get_binding(scalar caller) . "::DumpFile"}(@_) }
    sub LoadFile { &{get_binding(scalar caller) . "::LoadFile"}(@_) }
}

sub yaml { die }

sub dump {
    my $self = shift;
    return $self->binding->dump(@_);
}

sub load {
    my $self = shift;
    return $self->binding->load(@_);
}

sub emit {
    my $self = shift;
    return $self->binding->emit(@_);
}

sub parse {
    my $self = shift;
    return $self->binding->parse(@_);
}

sub _get_binding {
    my $package = shift;
    my $implementation = $YAML::_package_to_implementation->{$package}
      or croak "No YAML implmentation module found for package '$package'. Maybe you forgot to 'use YAML' in that package.";
    return $implementation->new;
}

sub grep_implemntation_list {
    my $class = shift;

    my $implementations = [];
    while (@_) {
        last unless $_[0] =~ /^-[A-Z]/;
        my $suffix = shift;
        $suffix =~ s/-/::/g;
        push @$implementations, "YAML$suffix";
    }
    @$implementations = $YAML::_implementation_list
        unless @$implementations;

    return ($implementations, @_);
}

sub load_implementation {
    my $class = shift;
    my $implementations = shift;

    for my $implementation (@$implementations) {
        my $path = "$implementation.pm";
        $path =~ s!::!/!g;
        if ($INC{$path} or eval "require $implementation; 1") {
            return $implementation;
        }
    }
    return;
}

sub generate_exportable_subroutines {
    my $class = shift;

    my $yaml = sub {
        return __PACKAGE__->new(@_);
    };
    return sub{}, sub{}, sub{}, sub{}, $yaml;
}

1;

=encoding utf-8

=head1 NAME

YAML - YAML Ain't Markup Language

=head1 WARNING

This is a very early version, and should simply not be used.

=head1 NOTE

The module "YAML" is intended to soon become the new YAML.pm. It is a
frontend API module that does no real work on its own, but instead
loads the YAML module you want to use. I'm releasing it to CPAN, so
people can start playing with the new API but not upset their
production/important code.

When YAML becomes YAML, the classic YAML.pm will be renamed to
YAML::Old. You can get the exact same behavior with:

    use YAML-Old;

for now, you can try:

    use YAML-Old;

If you use YAML now, when it becomes YAML.pm the only thing you will
need to do is change 'YAML' to 'YAML' in the 'use YAML' line of your
code. In other words, when I make the "switch", all I will do is
C<s/YAML/YAML/g> and remove this NOTE section from the documentation.

=head1 SYNOPSIS

    use YAML;              # Use the best YAML implementation available
    use YAML-XS;           # Use only YAML::XS, but with standard YAML API
    use YAML-XS,-Perl;     # Use either YAML::XS or YAML::Perl

    my $y = yaml;           # Create a new YAML object. Same as:
    my $y = YAML->new->implementation('YAML::XS');

    $YAML::UseCode = 1;     # Old global flags still work, but consistently
                            # between implementations
    Dump Load $object;      # Old Dump Load interface still exists

    yaml->dump($object);    # New dump interface
    yaml->load($yaml);      # New load interface
    yaml->indent(4)         # Dump to a file with various options
        ->file('foo.yaml')
        ->use_code
        ->dump(@objects);

=head1 DESCRIPTION

YAML.pm is the front end module API module for all of the various
backend YAML implementation modules. The current YAML implementation
modules are:

    - YAML::Old - The old, "classic", woefully inadequate YAML.pm
    - YAML::XS - The newer very fast and very correct YAML module
    - YAML::Syck - The older very fast but less correct YAML module
    - YAML::Perl - The Perl port of PyYaml
    - YAML::Tiny - Adam's Tiny subset of YAML module

All of these implementation modules use the familiar Dump/Load API.
YAML continues to support this simple API, but also exposes newer, more
powerful APIs. Note that not all of the API options can be used with
every implementation module. YAML will attempt to let you know when you
are doing something that is not supported.

When you C<use> YAML, you can let it choose an appropriate YAML
implementation, or you can specify which one(s) should be used. YAML
will load the appropriate implemenation module or it will die with the
appropriate error msg.

    use YAML-XS;       # Use only the YAML::XS implementation
    use YAML-XS,-Perl; # Use either YAML::XS or YAML::Perl implementation
    use YAML-Best;     # Same as above

    use YAML-Any;      # Same as:
    use YAML-XS,-Perl,-Syck,-Old,-Tiny;

=head1 EXPORT BEHAVIOR

=head1 Dump/Load API

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2008, 2009. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

__END__
# sub export_yaml {
#     my $implementations = ();
#     for my $module (@$implementations) {
#         if ($package->load_implementation($module)) {
#             no strict 'refs';
#             *{"${package}::yaml"} = sub {
#                 return 'YAML'->new()->implementation($module);
#             };
#             return;
#         }
#     }
#     my $msg = "Failed to load YAML implementation module. Could not find a binding module for" .
#         ((@$implementations > 1) ? " one of: " : ": ") .
#         join ', ', @$implementations;
#     croak($msg)
# }



#     my $implementation = shift;
#     my $binding = $implementation;
#     $binding =~ s/^YAML::(.*)$/YAML::Bind::$1/
#         or die "Error loading YAML binding module for '$implementation'";
#     eval "use $binding; \$YAML::_package_to_implementation->{$package} = '$implementation'";
#     return 0 if $@;
#     $YAML::_package_to_implementation->{$use_package} = $binding;
#     return 1;

use YAML;
yaml(
    implementation =>
    option1 =>
)
->loader
  ->load
  ->next
->dumper
  ->dump
->stream
->open
->close
->{binding}
