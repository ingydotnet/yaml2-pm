use t::TestYAML 'no_plan'; # tests => 5;
use t::YAMLFaker qw(YAML::Perl YAML::Old);
use YAML2();

test_export('Y1', 'use YAML2', '11001');
test_export('Y2', 'use YAML2-Old', '11001');
test_export('Y3', "use YAML2 'LoadFile'", '00010');
test_export('Y4', "use YAML2-Old, 'LoadFile'", '00010');
test_export('A1', 'use YAML2::Any', '11000');
# test_export('A2', 'use YAML2::Any-Old', '11001');
test_export('A3', "use YAML2::Any 'LoadFile'", '00010');

test_export('YAML2', 'YAML2 already has ', '11111');
YAML2::Dump(42);
no warnings 'once';
    is $YAML::Perl::last_called, 'Dump', 'Called the right YAML::Dump';


__END__
# use YAML;
# YAML::Dump();
# 
# 
# use YAML::Any();
# YAML::Any::Dump();




# package A4;
# use YAML2 'LoadFile';
# 
# package A5;
# eval "use YAML2::Any 'yaml'";
# $A5::Error = $@;
# 
# package A6;
# use YAML2::Any -XS, -Old;


# use YAML;
# use YAML-XS;
# use YAML-XS,-Perl;
# use YAML-XS => 'yaml=yamlxs';
# use YAML ':all';
# use YAML qw(Dump Load DumpFile LoadFile yaml);

# Dump(...);
# YAML::Dump(...);

