#!perl6

use v6;

use Test;
use IO::Glob;

use lib 't/lib';
use Test::Glob;

{
    my @files = dirio("t/fixtures").dir(test => glob('*.md')).sort;
    is @files.elems, 2;
    is @files[0], dirio "t/fixtures/bar.md";
    is @files[1], dirio "t/fixtures/foo.md";
}

{
    my @files = dirio("t/fixtures").dir(test => glob('foo.*')).sort;
    is @files.elems, 2;
    is @files[0], dirio "t/fixtures/foo.md";
    is @files[1], dirio "t/fixtures/foo.txt";
}

{
    my @files = dirio("t/fixtures").dir(test => glob(*)).sort;
    is @files.elems, 6;
    is @files[0], dirio "t/fixtures/.";
    is @files[1], dirio "t/fixtures/..";
    is @files[2], dirio "t/fixtures/bar.md";
    is @files[3], dirio "t/fixtures/bar.txt";
    is @files[4], dirio "t/fixtures/foo.md";
    is @files[5], dirio "t/fixtures/foo.txt";
}

done-testing;
