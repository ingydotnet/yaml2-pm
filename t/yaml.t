use t::TestYAML 'no_plan'; # tests => 5;
use t::YAMLFaker qw(YAML::Perl YAML::Old);
use YAML;

ok defined(&yaml), 'yaml is exported';

my $y1 = yaml;

is $y1->binding->implementation, 'YAML::Perl',
    'YAML binding object has correct implementation';
