use v6;

use Test;
use IO::Glob;

use lib 't/lib';
use Test::Glob;

{
    my @files = glob(dirstr('t/deep-fixtures/*/*/foo.md')).dir.sort;
    is @files.elems, 2;
    is @files[0], dirio('t/deep-fixtures/a/a/foo.md');
    is @files[1], dirio('t/deep-fixtures/c/c/foo.md');
}

{
    my @files = glob(dirstr('t/deep-fixtures/*/*/bar.md')).dir.sort;
    is @files.elems, 2;
    is @files[0], dirio('t/deep-fixtures/a/a/bar.md');
    is @files[1], dirio('t/deep-fixtures/b/a/bar.md');
}

done-testing;
