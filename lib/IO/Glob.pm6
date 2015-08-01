unit class IO::Glob;

use v6;

class Globber {
    role Term { }
    class Match does Term { has $.smart-match is rw }
    class Expansion does Term { has @.alternatives }

    has @.terms where { .elems > 0 && all($_) ~~ Term };
    has @!matchers;

    method !compile-terms-ind($base, @terms is copy) {
        my $term = @terms.shift;

        my @roots;
        if $term ~~ Match {
            my $match = $term.smart-match;
            @roots = rx/$base$match/;
        }
        elsif $term ~~ Expansion {
           my @alts = $term.alternatives;
           @roots = @alts.map({ rx/$base$^alt/ });
       }
       else {
           die "unknown match term: $term";
       }

       if @terms { @roots.map({ self!compile-terms-ind($^base, @terms) }) }
       else { @roots }
    }
    method !compile-terms() {
        return if @!matchers;
        @!matchers = self!compile-terms-ind(rx/<?>/, @.terms).map({rx/^$_$/});
    }

    multi method ACCEPTS(Str:U $) returns Bool:D { False }
    multi method ACCEPTS(Str:D $candidate) returns Bool:D {
        self!compile-terms;
        $candidate ~~ any(@!matchers);
    }
}

# Unlike File::Glob in Perl 5, we don't make a bunch of options to turn off each
# kind of feature. Instead, we give them the option to pick a grammar. They are
# free to subclass a grammar as simple or complicated as they like and we give
# them the obvious grammars to begin with.
grammar Simple {
    token TOP {
        <term>+
        { make $<term>».made }
    }

    token term {
        || <match>
           { make Globber::Match.new(:smart-match($<match>.made)) }
        || <expansion>
           { make Globber::Expansion.new(:alternatives($<expansion>.made)) }
        || <escape>
           { make Globber::Match.new(:smart-match($<escape>.made)) }
        || <char>
           { make Globber::Match.new(:smart-match($<char>.made)) }
    }

    proto token match {*}
    token match:sym<*> {
        <!after "\\"> <sym>
        { make rx/.*?/ }
    }
    token match:sym<?> {
        <!after "\\"> <sym>
        { make rx/./ }
    }

    proto token expansion { * }

    token escape { "\\" <escape-sym> { make $<escape-sym>.Str } }

    proto token escape-sym { * }
    token escape-sym:sym<*> { <sym> }
    token escape-sym:sym<?> { <sym> }

    token char { $<char> = . { make $<char>.Str } }
}

grammar BSD is Simple {
    token TOP { <term>+ }

    token match:character-class {
        <!after "\\"> '['
            $<not>   = [ "!"? ]
            $<class> = [ <-[ \] ]>+ ]
        ']'

        {
            my @class = $<class>.Str.comb;
            make $<not> ?? rx{@class} !! rx{<!before @class> .}
        }
    }

    token expansion:alternatives {
        <!after "\\"> '{'
            <list=.comma-list>
        '}'

        { make my @list= ([~] $<list>).split(',') }
    }

    token comma-list {
        [ <-[ , \} ]>+ ]+ % ','
    }

    token expansion:home-dir {
        <!after "\\"> '~' $<user> = [ <-[/]>+ ]?

        { make $<user> ?? [ 'NYI' ]<> !! [ $*HOME ]<> }
    }

    token escape-sym:sym<[> { <sym> }
    token escape-sym:sym<]> { <sym> }
    token escape-sym:sym<{> { <sym> }
    token escape-sym:sym<}> { <sym> }
    token escape-sym:sym<~> { <sym> }
}

has Str $.pattern;
has IO::Spec $.spec = $*SPEC;

has $.grammar = BSD.new;
has Globber $!globber;
has Globber @!globbers;

method !compile-glob() {
    $!globber = Globber.new(
        terms => $!grammar.parse($!pattern)<term>.map({.made}),
    );
}

method !compile-globs() {
    my @parts = $.pattern.split($.spec.dir-sep);
    @!globbers = @parts.map({
        Globber.new(
            terms => $!grammar.parse($^pattern)<term>.map({.made}),
        );
    });
}

method dir(Cool $path = '.') returns List:D {
    self!compile-globs;

    my $current = $path.IO;
    return []<> unless $current.d;

    my @globbers = @!globbers;

    # Depth-first-search... commence!
    my @open-list = \(:path($current), :@globbers);
    my @result;
    while @open-list {
        my (:$path, :@globbers) := @open-list.shift;

        if @globbers {
            my ($globber, @remaining) = @globbers;
            @open-list.unshift: $path.dir(test => $globber)\
                .map({
                    \(:$^path, :globbers(@remaining))
                });
        }
        else {
            @result.push: $path;
        }
    }

    @result;
}

multi method ACCEPTS(Str:U $) returns Bool:D { False }
multi method ACCEPTS(Str:D(Any) $candidate) returns Bool:D {
    self!compile-glob;
    $candidate ~~ $.globber
}

multi sub glob(Str:D $pattern) returns IO::Glob:D is export {
    IO::Glob.new(:$pattern);
}
multi sub glob(Whatever $) returns IO::Glob:D is export {
    IO::Glob.new(:pattern('*'));
}
