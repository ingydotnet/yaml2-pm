use lib '../yaml-perl-pm/lib';
use t::TestYAML;

plan((eval {require YAML::Perl; 1})
    ? (tests => 2)
    : (skip_all => "requires YAML::Perl")
);

use YAML-Perl;
require YAML::Perl::Events;

my $yaml = "42: 43\n";
my @events = map {
    chomp;
    my ($name, $value) = split;
    "YAML::Perl::Event::$name"->new(
        $value ? (
            value => $value,
        ) : (),
    );
} <DATA>;

my @events1 = @events;
my $iterator = sub {
    return @events1 ? shift(@events1) : ();
};

is yaml->emit($iterator), $yaml, 'yaml->emit works with iterator';
is yaml->emit(@events), $yaml, 'yaml->emit works with list';

__DATA__
StreamStart
DocumentStart
MappingStart
Scalar 42
Scalar 43
MappingEnd
DocumentEnd
StreamEnd
