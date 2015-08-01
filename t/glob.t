#!perl6

use v6;

use Test;
use IO::Glob;

isa-ok glob('*'), IO::Glob;

# my @files = glob('*').list;
# is @files, ('foo.txt'.IO, 'bar.txt'.IO, 'foo.md'.IO, 'bar.md'.IO);

my $star-foo = glob('*foo');
ok 'foo' ~~ $star-foo;
ok 'blahfoo' ~~ $star-foo;
ok !('fooblah' ~~ $star-foo);
ok !('bar' ~~ $star-foo);

my $dqs = glob('.??*');
ok !('foo' ~~ $dqs);
ok '.foo' ~~ $dqs;
ok !('.f' ~~ $dqs);
ok '.bar.foo' ~~ $dqs;
ok !('..' ~~ $dqs);
ok '...' ~~ $dqs;

my $star = glob(*);
ok 'foo' ~~ $star;
ok '.' ~~ $star;
ok '..' ~~ $star;
ok 'bsadhfwerowhefl;kasjdf' ~~ $star;
ok '' ~~ $star;

done;
