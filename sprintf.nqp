#! nqp

sub sprintf($format, *@arguments) {
    my $directive := /'%' <[s%]>/;

    my $dircount := +match($format, $directive, :global) - +match($format, /'%%'/, :global);
    my $argcount := +@arguments;

    nqp::die("Too few directives: found $dircount, fewer than the $argcount arguments after the format string")
        if $dircount < $argcount;

    nqp::die("Too many directives: found $dircount, but only $argcount arguments after the format string")
        if $dircount > $argcount;

    my $argument_index := 0;
    sub inject($match) {
        if ~$match eq '%s' {
            return @arguments[$argument_index++];
        }
        elsif ~$match eq '%%' {
            return '%';
        }
    }

    return subst($format, $directive, &inject, :global);
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

plan(8);

ok( sprintf('Walter Bishop') eq 'Walter Bishop', 'no directives' );

ok( sprintf('Peter %s', 'Bishop') eq 'Peter Bishop', 'one %s directive' );
ok( sprintf('%s %s', 'William', 'Bell') eq 'William Bell', 'two %s directives' );

dies_ok({ sprintf('%s %s', 'Dr.', 'William', 'Bell') }, 'arguments > directives' );
ok( $die_message eq 'Too few directives: found 2, fewer than the 3 arguments after the format string',
    'arguments > directives error message' );

dies_ok({ sprintf('%s %s %s', 'Olivia', 'Dunham') }, 'directives > arguments' );
ok( $die_message eq 'Too many directives: found 3, but only 2 arguments after the format string',
    'directives > arguments error message' );

ok( sprintf('%% %% %%') eq '% % %', '%% escape' );
