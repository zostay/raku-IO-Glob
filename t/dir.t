#!perl6

use v6;

use Test;
use IO::Glob;

use lib 't/lib';
use Test::Glob;

{
    my @files = glob(dirstr 't/fixtures/*.md').dir.sort;
    is @files.elems, 2;
    is @files[0], dirio 't/fixtures/bar.md';
    is @files[1], dirio 't/fixtures/foo.md';
}

{
    my @files = glob(dirstr 'fixtures/foo.*').dir('t').sort;
    is @files.elems, 2;
    is @files[0], dirio "t/fixtures/foo.md";
    is @files[1], dirio "t/fixtures/foo.txt";
}

{
    my @files = glob(*).dir(dirstr "t/fixtures").sort;
    is @files.elems, 6;
    is @files[0], dirio "t/fixtures/.";
    is @files[1], dirio "t/fixtures/..";
    is @files[2], dirio "t/fixtures/bar.md";
    is @files[3], dirio "t/fixtures/bar.txt";
    is @files[4], dirio "t/fixtures/foo.md";
    is @files[5], dirio "t/fixtures/foo.txt";
}

{
    my @files = glob(dirstr 't/fixtures/{foo,bar}.md').dir;
    is @files.elems, 2;
    is @files[0], dirio 't/fixtures/foo.md';
    is @files[1], dirio 't/fixtures/bar.md';
}

{
    my @files = glob(dirstr 't/fixtures/{bar,foo}.md').dir;
    is @files.elems, 2;
    is @files[0], dirio 't/fixtures/bar.md';
    is @files[1], dirio 't/fixtures/foo.md';
}

done-testing;
