use Test;
use IO::Glob :TESTING;

use lib 't/lib';
use Test::Glob;

for <.* .? ../../* *.?> {
    my $parsed =  IO::Glob::Simple.parse($_);
    ok($parsed, "Parse $_ is OK" );
    ok($parsed<term>, "Parsed term $_ is OK" );
}

for <__. _% > {
    my $parsed = IO::Glob::SQL.parse($_);
    ok( $parsed, "Parse $_ is OK" );
    ok($parsed<term>, "Parsed term $_ is OK" );
    ok simplify( $parsed<term>.map: *.made ), "Can simplify";
}
