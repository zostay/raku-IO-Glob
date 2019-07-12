use v6;

use Test;
use IO::Glob;

my @root = dir('/').sort».Str;

subtest 'root-in-the-glob-with-relative-dir-dies' => {
    throws-like {
        glob("/*").dir
    }, X::AdHoc, message => /'relative search origin'/;
}

subtest 'root-in-the-glob' => {
    my @files = glob("/*").dir("/")».Str.grep(none('/.', '/..')).sort;
    is-deeply @files, @root;
}

subtest 'root-in-the-dir' => {
    my @files = glob("*").dir("/").».Str.grep(none('/.', '/..')).sort;
    is-deeply @files, @root;
}

subtest 'root-via-accept' => {
    my @files = @root.grep(glob("/*"));
    is-deeply @files, @root;
}

done-testing;
