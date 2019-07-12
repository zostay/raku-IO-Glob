use v6;

unit module Test::Glob;

sub dirstr($path) is export { $path.split('/').join($*SPEC.dir-sep) }
sub dirio($path) is export { dirstr($path).IO }
