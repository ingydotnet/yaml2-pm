use lib '../yaml-perl-pm/lib';
use t::TestYAML;

no_diff();

plan((eval {require YAML::Perl; 1})
    ? (tests => 1)
    : (skip_all => "requires YAML::Perl")
);

use YAML-Perl;
require YAML::Perl::Events;

my $yaml = "---\n42: 43\n";
my @events = map {
    chomp;
    my ($name, $value) = split;
    "YAML::Perl::Event::$name"->new(
        $value ? (
            value => $value,
        ) : (),
    );
} <DATA>;

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
