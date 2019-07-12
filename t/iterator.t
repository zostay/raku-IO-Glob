#!perl6

use v6;

use Test;
use IO::Glob;

use lib 't/lib';
use Test::Glob;

{
    my @files = glob(dirstr 't/fixtures/*.md').sort;
    is @files.elems, 2;
    is @files[0], dirio 't/fixtures/bar.md';
    is @files[1], dirio 't/fixtures/foo.md';
}

{
    my @files = glob(dirstr 't/fixtures/{foo,bar}.md');
    is @files.elems, 2;
    is @files[0], dirio 't/fixtures/foo.md';
    is @files[1], dirio 't/fixtures/bar.md';
}

{
    my @files = glob(dirstr 't/fixtures/{bar,foo}.md');
    is @files.elems, 2;
    is @files[0], dirio 't/fixtures/bar.md';
    is @files[1], dirio 't/fixtures/foo.md';
}

done-testing;
