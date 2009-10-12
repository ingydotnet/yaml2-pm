package YAML2;

$YAML2::VERSION = '0.01';

die <<'...';

Don't 'use YAML2;'.

See:

    perldoc YAML2

for more information.
...

1;

=encoding utf-8

=head1 NAME

YAML2 - The New, Experimental YAML.pm

=head1 SYNOPSIS

Do not C<use YAML2;>

C<YAML2> is the module distribution name for the new, improved C<YAML>
module.

Therefore:

    use YAML;

    yaml->emit(yaml->parse($yaml));


=head1 WARNING

DO NOT INSTALL YAML2 IN PRODUCTION ENVIRONMENTS!!!

C<YAML2> is the temporary distribution name for the new YAML.pm.
Installing this distribution will replace your YAML.pm module with
this new one.

You SHOULD do this if you want to play with the new YAML module.

You SHOULD NOT do this in an environment that critically depends on YAML.pm.

=head1 DESCRIPTION

There are many YAML implementations available.

  - YAML.pm - The old pure Perl YAML module
  - YAML::Old - The new name for the old YAML
  - YAML::Syck - The old C/XS YAML module
  - YAML::XS - The new and best C/XS YAML 
  - YAML::Perl - The new and most complete pure Perl YAML module
  - YAML::Tiny - A tiny and incomplete subset of YAML

Since YAML.pm has been moved to YAML::Old, the plan is to make YAML.pm into an
interface only module. So you always use YAML, but YAML loads the
implementation module of your choice or the best one available.

This is a complete change for YAML.pm so it will take time to stabilize.
During this period you can install the YAML2 distribution, and it will replace
YAML.pm on your system with the new style YAML.pm. Like this:

    sudo cpan YAML2

The point of YAML2 is to experiment with the new YAML.pm. To return to using
the old YAML.pm, just install the YAML distribution. Like this:

    sudo cpan YAML

To use the new YAML, do stuff like this:

    use YAML;

    use YAML '-Old';  # Uses the YAML::Old implementation

    use YAML -XS;     # Quotes are not needed for -flags

    use YAML-Perl;    # Intuitive look and feel

    use YAML -XS, -Perl;  # Try to use YAML::XS, then try YAML::Perl, else die

If everything goes as planned, existing code should continue to work fine,
while new and powerful APIs become available.

For the complete documentation of the new YAML.pm, install YAML2 and run:

    perldoc YAML

=head1 ROADMAP

It is my desire to get the YAML toolchain stable and robust. This is an
ongoing process. This list of tasks is the ROADMAP for the YAML modules.

=over

=item Finish YAML2

YAML2 is the distribution name of the new YAML.pm. The new YAML.pm does these
things:

    - Loads a proper YAML implementation module.
    - Exposes the standard Dump/Load API (if available).
    - Exposes the new OO API (as appropriate to the implementation).
    - Exposes the parse/emit API (if available).

=item Finish YAML::Perl

YAML::Perl is a pure Perl port of PyYAML. PyYAML is the de facto reference
implementation for YAML. It is very high quality, and implements the entire
YAML stack.

ALl of the Python code has been ported. Still need to get all the tests
passing.

=item Expose streaming API for YAML::XS

YAML::Perl has parse and emit methods for doing streaming processing. These
could easily be exposed in YAML::XS for greater speed, but the work has not
yet been done.

=item Replace YAML.pm with the YAML2 version.

Once the new YAML has been proven to be very stable, it will completely
replace the code that has become YAML::Old.

To start with, the YAML.pm installation will always require YAML::Old and will
use it as the implementation by default.

=back

=head1 AUTHOR

Ingy döt Net <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2008, 2009. Ingy döt Net.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
