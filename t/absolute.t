use v6;

use Test;
use IO::Glob;

use lib 't/lib';
use Test::Glob;

my $root-dir = root-dir;

my @root = dir($root-dir).sort».Str;

subtest 'root-in-the-glob-with-relative-dir-dies' => {
    throws-like {
        glob("$root-dir*").dir
    }, X::AdHoc, message => /'relative search origin'/;
}

subtest 'root-in-the-glob' => {
    my @files = glob("$root-dir*").dir($root-dir)».Str.grep(none("$root-dir.", "$root-dir..")).sort;
    is-deeply @files, @root;
}

subtest 'root-in-the-dir' => {
    my @files = glob("*").dir($root-dir).».Str.grep(none("$root-dir.", "$root-dir..")).sort;
    is-deeply @files, @root;
}

subtest 'root-via-accept' => {
    my @files = @root.grep(glob("$root-dir*"));
    is-deeply @files, @root;
}

done-testing;
