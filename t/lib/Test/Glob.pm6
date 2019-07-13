use v6;

unit module Test::Glob;

use Test;
sub dirstr($path) is export { $path.split('/').join($*SPEC.dir-sep) }
sub dirio($path) is export { dirstr($path).IO }

sub root-dir is export {
    given $*SPEC {
        when IO::Spec::Win32 { "C:\\" }
        when IO::Spec::Cygwin { "C:/" }
        default { "/" }
    }
}
