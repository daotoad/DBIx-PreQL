use strict;
use warnings;
use Carp   qw<croak>;
use Data::Dumper;
use t::PreQL qw< build_query_ok >;

use Test::More tests => 6;

build_query_ok(
    { query => '*   blah', data => {} },
    { sql => 'blah', parameters => [] },
    'TAG_ALWAYS at start of line with no replacement'
);

build_query_ok(
    { query => '    *   blah', data => {} },
    { sql => 'blah', parameters => [] },
    'TAG_ALWAYS indented with no replacement'
);

build_query_ok(
    { query => ' *   blah=?foo?   ', data => {} },
    { exception => [ qr/foo/, qr/no|missing/i, qr/named placeholder/i ] },
    'TAG_ALWAYS dies with missing placeholder data'
);

build_query_ok(
    { query => ' *   blah=?foo?', data => {foo => '123'} },
    { sql => 'blah=?', parameters => [ 123 ] },
    'TAG_ALWAYS placeholder substitution occurs'
);

build_query_ok(
    { query => ' *   blah=?"foo?', data => {foo => '123'} },
    { sql => 'blah=123', parameters => [ ] },
    'TAG_ALWAYS literal placeholder substitution occurs'
);

build_query_ok(
    { query => ' *   blah=!foo!   ', data => {} },
    { exception => [ qr/foo/, qr/dependency marker/i ] },
    'TAG_ALWAYS dies with dependency marker'
);



