package t::YAMLFaker;
use strict;

sub import {
    my $pkg = shift;
    generate_fake($_) for (@_);
}

sub generate_fake {
    my $module = shift;
    my $path = $module;
    $path =~ s!::!/!g;
    $path .= '.pm';
    $INC{$path} = $module;

    my $code = "package $module;\n";
    for my $sub (qw(import Dump Load DumpFile LoadFile)) {
        $code .= <<"...";
sub $sub {
    \$$module\::last_called = '$sub';
}
...
    }
    $code .= "1;\n";

    eval $code or die "$@\n\n$code\n";
}

1;
