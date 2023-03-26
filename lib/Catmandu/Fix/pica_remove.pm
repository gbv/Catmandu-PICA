package Catmandu::Fix::pica_remove;

use Catmandu::Sane;

our $VERSION = '1.11';

use Moo;
use Catmandu::Fix::Has;
use PICA::Path;
use Scalar::Util 'reftype';

has path => (
    fix_arg => 1,
    coerce  => sub { PICA::Path->new( $_[0] ) }
);

sub fix {
    my ( $self, $data ) = @_;
    return $data if reftype $data->{record} ne 'ARRAY';

    # TODO: put this into PICA::Data

    my $path   = $self->path;
    my $fields = $data->{record};

    if ( $path->subfields ) {
        my $subfield_regex = $path->{subfield};
        $fields = [];

        for my $field ( @{ $data->{record} } ) {
            if ( $path->match_field($field) ) {
                my @result = @$field[ 0 .. 1 ];
                for ( my $i = 2 ; $i < @$field ; $i += 2 ) {
                    if ( $field->[$i] !~ $subfield_regex ) {
                        push @result, $field->[$i], $field->[ $i + 1 ];
                    }
                }
                if ( @result > 2 ) {
                    push @result,  $field->[-1] if @$field % 2;
                    push @$fields, \@result;
                }
            }
            else {
                push @$fields, $field;
            }
        }
    }
    else {
        $fields = [ grep { !$path->match_field($_) } @$fields ];
    }

    $data->{record} = $fields;

    return $data;
}

=head1 NAME

Catmandu::Fix::pica_remove - remove PICA (sub)fields

=head1 SYNOPSIS

    # remove all 021A fields
    pica_remove('021A')

    # remove all $9 subfields from all level 0 fields
    pica_remove('0...$9')

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 pica_remove(PATH)

Delete all (sub)fields from the PICA record, referenced by a L<PICA Path expression|https://format.gbv.de/query/picapath>.
Fields are also removed if all subfields have been removed.

=head2 SEE ALSO

L<PICA::Path>, L<Catmandu::Fix::pica_keep>

=cut

1;
