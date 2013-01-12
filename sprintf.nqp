#! nqp

sub sprintf($format, *@arguments) {
    my $dircount := +match($format, /'%s'/, :global);
    my $argcount := +@arguments;

    nqp::die("Too few directives: found $dircount, fewer than the $argcount arguments after the format string")
        if $dircount < $argcount;

    my $argument_index := 0;
    sub inject($match) {
        return @arguments[$argument_index++];
    }

    return subst($format, /'%s'/, &inject, :global);
}

my $die_message := 'unset';

sub dies_ok(&callable, $description) {
    &callable();
    ok(0, $description);
    return '';

    CATCH {
        ok(1, $description);
        $die_message := $_;
    }
}

plan(5);

ok( sprintf('Walter Bishop') eq 'Walter Bishop', 'no directives' );

ok( sprintf('Peter %s', 'Bishop') eq 'Peter Bishop', 'one %s directive' );
ok( sprintf('%s %s', 'William', 'Bell') eq 'William Bell', 'two %s directives' );

dies_ok({ sprintf('%s %s', 'Dr.', 'William', 'Bell') }, 'arguments > directives' );
ok( $die_message eq 'Too few directives: found 2, fewer than the 3 arguments after the format string',
    'arguments > directives error message' );
