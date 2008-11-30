use t::TestYAML tests => 1;

use YAML2-XS;

is Dump(42), "--- 42\n", 'Dump works';
