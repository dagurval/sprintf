#! nqp

sub sprintf($format, *@arguments) {
    my $argument_index := 0;
    sub inject($match) {
        return @arguments[$argument_index++];
    }

    return subst($format, /'%s'/, &inject, :global);
}

plan(3);

ok( sprintf('Walter Bishop') eq 'Walter Bishop', 'no directives' );

ok( sprintf('Peter %s', 'Bishop') eq 'Peter Bishop', 'one %s directive' );
ok( sprintf('%s %s', 'William', 'Bell') eq 'William Bell', 'two %s directives' );
