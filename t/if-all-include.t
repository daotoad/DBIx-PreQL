use strict;
use warnings;
use Carp   qw<croak>;
use Data::Dumper;

use t::PreQL qw< build_query_ok >;

use Test::More tests => 9;

build_query_ok(
    { query => '&   blah', data => {} },
    { exception => [ qr/no|missing/i, qr/dependency marker/i, qr/named placeholder/i ] },
    'TAG_IF_ALL dies with no dependency markers or named placeholders',
);

build_query_ok(
    { query => '&   blah=?foo?', data => { bar => 123 } },
    { sql => '', parameters => [] },
    'TAG_IF_ALL is skipped when placeholder does not match'
);

build_query_ok(
    { query => '&   blah=?foo?', data => { foo => 123 } },
    { sql => 'blah=?', parameters => [123] },
    'TAG_IF_ALL is kept with substitution with single placeholder match'
);

build_query_ok(
    { query => '    &   blah=?foo?', data => { foo => 123 } },
    { sql => 'blah=?', parameters => [123] },
    'TAG_IF_ALL is kept with substitution with single placeholder match when line is indented'
);


build_query_ok(
    { query => '&   blah !foo!', data => { bar => 123 } },
    { sql => '', parameters => [] },
    'TAG_IF_ALL is skipped when dependency does not match'
);

build_query_ok(
    { query => '&   blah !foo!', data => { foo => 123 } },
    { sql => 'blah', parameters => [] },
    'TAG_IF_ALL is kept with substitution with single dependency match'
);


build_query_ok(
    { query => '&   blah=?foo? !bar!', data => { foo => 123, bar => 987 } },
    { sql => 'blah=?', parameters => [123] },
    'TAG_IF_ALL is kept with substitution with mixed match'
);

build_query_ok(
    { query => '&   blah=?foo? !bar!', data => { bar => 987 } },
    { sql => '', parameters => [] },
    'TAG_IF_ALL is skipped on partial match'
);

build_query_ok(
    { query => '&   blah=?foo? !bar!', data => { foo => 987 } },
    { sql => '', parameters => [] },
    'TAG_IF_ALL is skipped on partial match'
);

