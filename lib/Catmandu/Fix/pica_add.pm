package Catmandu::Fix::pica_add;

our $VERSION = '0.19';

use Catmandu::Sane;
use Moo;
use Catmandu::Fix::Has;
use PICA::Path;
use Carp qw(confess);

has path      => ( fix_arg => 1 );
has pica_path => ( fix_arg => 1 );
has record    => ( fix_opt => 1 );
has force_new => ( fix_opt => 1 );

with 'Catmandu::Fix::SimpleGetValue';

sub emit_value {
    my ( $self, $add_value, $fixer ) = @_;

    my $perl = "if (is_string(${add_value})) {";

    my $record_key  = $fixer->emit_string( $self->record // 'record' );
    my $pica_path   = PICA::Path->new($self->pica_path);

    my ($field, $occurrence, $subfield) = map {
        defined $_ ? do {
            s/^\(\?[^:]*:(.*)\)$/$1/;
            s/\./*/g;
            $_ } : undef
        } ($pica_path->[0], $pica_path->[1], $pica_path->[2]);

    my ($field_regex, $occurrence_regex) = @$pica_path;

    confess "Can't use more than one subfield to add a value. ". length $subfield
        if length $subfield > 3;

    $subfield    = $fixer->emit_string( substr($subfield, 1, 1) );
    $field       = $fixer->emit_string( $field );
    $occurrence  = $fixer->emit_string( $occurrence // '' );

    my $field_regex_var    = $fixer->generate_var;
    $perl .= $fixer->emit_declare_vars( $field_regex_var, "qr{$field_regex}" );

    my $occurrence_regex_var;
    if (defined $occurrence_regex) {
        $occurrence_regex_var = $fixer->generate_var;
        $perl .= $fixer->emit_declare_vars( $occurrence_regex_var, "qr{$occurrence_regex}" );
    }

    my $data  = $fixer->var;
    my $added = $fixer->generate_var;

    $perl .= $fixer->emit_declare_vars($added);

    unless ($self->force_new) {
        $perl .= $fixer->emit_foreach(
            "${data}->{${record_key}}",
            sub {
                my $var  = shift;
                my $perl = "next if ${var}->[0] !~ ${field_regex_var};";
                if (defined $occurrence_regex) {
                    $perl .= "next if (!defined ${var}->[1] || ${var}->[1] !~ ${occurrence_regex_var});";
                }
                $perl .= "push \@{${var}}, (${subfield} => ${add_value}); ${added} = 1;";
            }
        );
    }

    $perl .= "push(\@{ ${data}->{${record_key}} }, "
          .  "[${field}, ${occurrence}, ${subfield} => ${add_value} ]) unless defined ${added}};";
}

1;
__END__

=head1 NAME

Catmandu::Fix::pica_add - add new fields or subfields to record

=head1 SYNOPSIS

    # Copy value of dc.identifier to PICA field 003A as subfield 0
    pica_add('dc.identifier', '003A0');
    
    # same as above, but use another record path ('pica')
    pica_add('dc.identifier', '003A0', record:'pica');
    
    # force the creation of a new field 003A
    pica_add('dc.identifier', '003A0', force_new:1);

=head1 DESCRIPTION

This fix adds a subfield with value of PATH to the PICA field.

If PICA field does not exist, it will be created.

=head1 FUNCTIONS

=head2 pica_add(PATH, PICA_PATH, [OPTIONS])

=head3 Options

=over

=item * record - alternative record key (default is 'record')

=item * force_new - force the creation of a new field

=back

=head1 SEE ALSO

See L<Catmandu::Fix::pica_set> for setting a new value to an existing subfield.

See L<Catmandu::Fix::pica_map> if you want to copy values from a PICA record.

See L<PICA::Path> for a definition of PICA path expressions and L<PICA::Data>
for more methods to process parsed PICA+ records.

=cut
