package t::PreQL;

use strict;
use warnings;
use Carp        qw<croak>;
use Test::More;
use Exporter    qw< import >;

our @EXPORT_OK = qw/ build_query_ok /;


use DBIx::PreQL;


sub build_query_ok {
    my( $args, $expect, $name ) = @_;

    my $query      = delete $args->{query};
    my $data       = delete $args->{data};
    my $wanted     = delete $args->{wanted};
    my $known_tags = delete $args->{known_tags};
    croak "Unknown test arguments for build_query() - @{[ join ', ', keys %$args ]}"
        if %$args;

    my %expect = (
        sql        => delete $expect->{sql},
        parameters => delete $expect->{parameters},
        exception  => delete $expect->{exception},
    );
    croak "Unknown keys in expect - @{[ join ', ', keys %$expect ]}"
        if %$expect;

    my %got;
    eval {
        ( $got{sql}, @{$got{parameters}} ) = DBIx::PreQL->build_query(
            query      => $query,
            data       => $data,
            wanted     => $wanted,
            known_tags => $known_tags,
        );
        1;
    } or do {
        $got{exception} = $@;
    };

    subtest $name => sub {

        for my $k (qw/ sql parameters /) {
            is_deeply( $got{$k}, $expect{$k}, "Found matching $k");
        }

        if( $expect{exception} && $got{exception} ) {
            my $ex = $expect{exception};
            if( ref $ex ) {
                my @matches = 'ARRAY' eq ref $ex ? @$ex : $ex;

                like( $got{exception}, $_, "exception matches pattern $_" )
                    for @matches;
            }
            else {
                is( $got{exception}, $ex );
            }
        }
        elsif( $got{exception} ) {
            fail "got unexpected exception";
            diag "$got{exception}";
        }
        elsif( $expect{exception} ) {
            fail "no exception recieved";
        }
        else {
            pass "no exception recieved";
        }

    };

}

1;
