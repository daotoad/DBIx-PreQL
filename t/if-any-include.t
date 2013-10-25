use strict;
use warnings;
use Carp   qw<croak>;
use Data::Dumper;

use t::PreQL qw< build_query_ok >;

use Test::More tests => 7;

build_query_ok(
    { query => '|   blah', data => {} },
    { exception => [ qr/no|missing/i, qr/dependency marker/i ] },
    'TAG_IF_ANY dies with no dependency markers',
);

build_query_ok(
    { query => '|   blah=?foo?', data => { foo => 123 } },
    { exception => [ qr/wrong tag/i, qr/named placeholder/i ] },
    'TAG_IF_ANY dies with named placeholder',
);

build_query_ok(
    { query => '|   blah !foo!', data => { foo => 123 } },
    { sql => 'blah', parameters => [] },
    'TAG_IF_ANY is kept with substitution with single placeholder match'
);

build_query_ok(
    { query => '    |   blah !foo!', data => { foo => 123 } },
    { sql => 'blah', parameters => [] },
    'TAG_IF_ANY is kept with substitution with single placeholder match when line is indented'
);


build_query_ok(
    { query => '|   blah !foo!', data => { bar => 123 } },
    { sql => '', parameters => [] },
    'TAG_IF_ANY is skipped when dependency does not match'
);

build_query_ok(
    { query => '|   blah !foo!', data => { foo => 123 } },
    { sql => 'blah', parameters => [] },
    'TAG_IF_ANY is kept with substitution with single dependency match'
);


build_query_ok(
    { query => '|   blah !foo! !bar!', data => { foo => 123 } },
    { sql => 'blah', parameters => [] },
    'TAG_IF_ANY is kept with substitution with partial match'
);


