package t::TestYAML;
use Test::Base -base;

@t::TestYAML::EXPORT = qw(test_export);

sub test_export {
    my ($package, $phrase, $flags) = @_;

    unless ($phrase =~ /\s$/) {
        my $code = $phrase;
        $phrase = "`$code` exports ";
        eval qq{ package $package; $code; };
        die "Error evaling `$code`: $@" if $@;
    }
    
    my @subs = qw(Dump Load DumpFile LoadFile yaml);
    while ($flags =~ s/(.)//) {
        my $exported = $1;
        my $sub = shift @subs or die;
        no strict 'refs';
        if ($exported) {
            ok defined &{"$package\::$sub"}, "$phrase'$sub'";
        }
        else {
            (my $phrase2 = $phrase) =~ s/exports/doesn't export/;
            ok not(defined &{"$package\::$sub"}), "$phrase2'$sub'";
        }
    }
}

1;
