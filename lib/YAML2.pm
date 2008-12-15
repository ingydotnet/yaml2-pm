package YAML2;

use 5.005003;
use strict;
use warnings;           # XXX remove this for 5.005003
use YAML2::Base -base;

$YAML2::VERSION = '0.10';
@YAML2::EXPORT = qw(yaml Dump Load);
@YAML2::EXPORT_OK = qw(DumpFile LoadFile freeze thaw);

$YAML2::_package_to_implementation = {};
$YAML2::_implementation_list = [qw(
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
    require YAML2::Bind::Perl;
    return YAML2::Bind::Perl->new();
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
    my $implementation = $YAML2::_package_to_implementation->{$package}
      or croak "No YAML2 implmentation module found for package '$package'. Maybe you forgot to 'use YAML2' in that package.";
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
    @$implementations = $YAML2::_implementation_list
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

=head1 NAME

YAML2 - YAML Ain't Markup Language

=head1 WARNING

This is a very early version, and should simply not be used.

=head1 NOTE

The module "YAML2" is intended to soon become the new YAML.pm. It is a
frontend API module that does no real work on its own, but instead
loads the YAML module you want to use. I'm releasing it to CPAN, so
people can start playing with the new API but not upset their
production/important code.

When YAML2 becomes YAML, the classic YAML.pm will be renamed to
YAML::Old. You can get the exact same behavior with:

    use YAML-Old;

for now, you can try:

    use YAML2-Old;

If you use YAML2 now, when it becomes YAML.pm the only thing you will
need to do is change 'YAML2' to 'YAML' in the 'use YAML' line of your
code. In other words, when I make the "switch", all I will do is
C<s/YAML2/YAML/g> and remove this NOTE section from the documentation.

=head1 SYNOPSIS

    use YAML2;              # Use the best YAML implementation available
    use YAML2-XS;           # Use only YAML::XS, but with standard YAML2 API
    use YAML2-XS,-Perl;     # Use either YAML::XS or YAML::Perl

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

YAML2.pm is the front end module API module for all of the various
backend YAML implementation modules. The current YAML implementation
modules are:

    - YAML::Old - The old, "classic", woefully inadequate YAML.pm
    - YAML::XS - The newer very fast and very correct YAML module
    - YAML::Syck - The older very fast but less correct YAML module
    - YAML::Perl - The Perl port of PyYaml
    - YAML::Tiny - Adam's Tiny subset of YAML module

All of these implementation modules use the familiar Dump/Load API.
YAML2 continues to support this simple API, but also exposes newer, more
powerful APIs. Note that not all of the API options can be used with
every implementation module. YAML2 will attempt to let you know when you
are doing something that is not supported.

When you C<use> YAML2, you can let it choose an appropriate YAML
implementation, or you can specify which one(s) should be used. YAML2
will load the appropriate implemenation module or it will die with the
appropriate error msg.

    use YAML2-XS;       # Use only the YAML::XS implementation
    use YAML2-XS,-Perl; # Use either YAML::XS implementation
    use YAML;           # Same as:
    use YAML-XS,-Perl,-Syck,-Old,-Tiny;

=head1 EXPORT BEHAVIOR

=head1 Dump/Load API

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2008. Ingy döt Net.

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
#     my $msg = "Failed to load YAML2 implementation module. Could not find a binding module for" .
#         ((@$implementations > 1) ? " one of: " : ": ") .
#         join ', ', @$implementations;
#     croak($msg)
# }



#     my $implementation = shift;
#     my $binding = $implementation;
#     $binding =~ s/^YAML::(.*)$/YAML2::Bind::$1/
#         or die "Error loading YAML2 binding module for '$implementation'";
#     eval "use $binding; \$YAML2::_package_to_implementation->{$package} = '$implementation'";
#     return 0 if $@;
#     $YAML2::_package_to_implementation->{$use_package} = $binding;
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
