use lib '../YAML-Perl/lib';
use t::TestYAML;

plan((eval {require YAML::Perl; 1})
    ? (tests => 16)
    : (skip_all => "requires YAML::Perl")
);

use YAML-Perl;

my $yaml = "aaa: 42\n";
my @wants = map { chomp; $_ } <DATA>;
my @want;

diag('Test iterator parse');
my $iterator = yaml->parse($yaml);
while (my $event = $iterator->()) {
    test($event);
}

diag('Test list context parse');
for my $event (yaml->parse($yaml)) {
    test($event);
}

sub test {
    my $event = shift;
    my $got = ref($event);
    $got =~ s/^YAML::Perl::Event:://;
    $got .= ' ' . $event->value
        if $got eq 'Scalar';
    @want = @wants unless @want;
    my $want = shift @want;
    is $got, $want, "Got event '$want'";
}

__DATA__
StreamStart
DocumentStart
MappingStart
Scalar aaa
Scalar 42
MappingEnd
DocumentEnd
StreamEnd
