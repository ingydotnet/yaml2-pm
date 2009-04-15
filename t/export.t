use t::TestYAML 'no_plan'; # tests => 5;
use t::YAMLFaker qw(YAML::Perl YAML::Old);
use YAML();

test_export('Y1', 'use YAML', '11001');
test_export('Y2', 'use YAML-Old', '11001');
test_export('Y3', "use YAML 'LoadFile'", '00010');
test_export('Y4', "use YAML-Old, 'LoadFile'", '00010');
test_export('A1', 'use YAML::Any', '11000');
# test_export('A2', 'use YAML::Any-Old', '11001');
test_export('A3', "use YAML::Any 'LoadFile'", '00010');

test_export('YAML', 'YAML already has ', '11111');
YAML::Dump(42);
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
# use YAML 'LoadFile';
# 
# package A5;
# eval "use YAML::Any 'yaml'";
# $A5::Error = $@;
# 
# package A6;
# use YAML::Any -XS, -Old;


# use YAML;
# use YAML-XS;
# use YAML-XS,-Perl;
# use YAML-XS => 'yaml=yamlxs';
# use YAML ':all';
# use YAML qw(Dump Load DumpFile LoadFile yaml);

# Dump(...);
# YAML::Dump(...);

