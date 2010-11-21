=begin pod

=head1 NAME

Facter::Util::Confine

=head1 DESCRIPTION

A restricting tag for fact resolution mechanisms.  The tag must be true
for the resolution mechanism to be suitable.

=end pod

class Facter::Util::Confine;

use Facter::Util::Values;

has $.fact is rw;
has @.values is rw;

# Add the restriction.  Requires the fact name, an operator, and the value
# we're comparing to.
method initialize($fact, *@values) {
    die "The fact name must be provided" unless $fact; # ArgumentError
    die "One or more values must be provided" if @values.elems == 0;
    $.fact = $fact;
    @.values = @values;
}

method to_s {    # XXX Str ?
    my $fact = $.fact;
    my $values = @.values.join(',');
    return "'$fact' '$values'";
}

# Evaluate the fact, returning true or false.
method true {

    unless my $fact = Facter.get_fact($.fact) {
        Facter.debug("No fact for $.fact");
        return False
    }

    my $value = Facter::Util::Values.convert($fact.value);

    return False if ! $value.defined;

    for @.values -> $v {
        $v = Facter::Util::Values.convert($v);
        next unless $v.WHAT == $value.WHAT;    # ruby's .class
        return True if $value == $v;
    }

    return False
}
