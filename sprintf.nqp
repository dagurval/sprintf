#! nqp

sub sprintf($format, *@arguments) {
    return $format;
}

plan(1);

ok( sprintf('Walter Bishop') eq 'Walter Bishop', 'no directives' );
