#! nqp

sub sprintf($format, *@arguments) {
    my $argument_index := 0;
    sub inject($match) {
        return @arguments[$argument_index++];
    }

    return subst($format, /'%s'/, &inject);
}

plan(2);

ok( sprintf('Walter Bishop') eq 'Walter Bishop', 'no directives' );

ok( sprintf('Peter %s', 'Bishop') eq 'Peter Bishop', 'one %s directive' );
