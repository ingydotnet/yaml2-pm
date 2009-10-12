use inc::Module::Install;

name 'YAML2';

all_from 'lib/YAML.pm';

requires 'YAML::Old' => 0;

WriteAll;
