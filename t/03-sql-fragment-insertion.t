
BEGIN {
    my @options = (
        '+ignore' => 'Data/Dumper',
        '+select' => 'DBIx::PreQL',
    );
    require Devel::Cover
        &&  Devel::Cover->import( @options )
        if  $ENV{COVER};
}

use strict;
use warnings;
use Data::Dumper;

use Test::More;

use_ok( 'DBIx::PreQL' );

my $array_of_array = [
  [ 'SELECT' ],
  [ "ARRAY,\nARRAY,", qw( arrayparam ) ],
  ['FROM table'],
  ['WHERE'],
  [ 'AND ARRAY AND ARRAY', qw( whereparam1 whereparam2 ) ],
];

my $pq = join "\n",
   'SELECT',
   'ARRAY,',
   'ARRAY',
   'FROM table',
   'WHERE',
   '    ARRAY AND ARRAY',
;
my @pp = qw< arrayparam  whereparam1 whereparam2 >;

for my $q ( $array_of_array ) {
    my( $query, @params ) = DBIx::PreQL->build_query(
        query       => $q,
        wanted      => ['A','C'],
        data        => {
            apple       => 1,
            apple2      => 1,
            banana      => 1,
            canteloupe  => 1,
            always_1    => 1,
            always_2    => 1,
        },
        keep_keys   => 1,
    );

    is( $query, $pq, 'Generated same query' );
    is_deeply( \@params, \@pp, 'Generated same keys' );
}

done_testing();
