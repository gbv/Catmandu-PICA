use strict;
use warnings;
use utf8;
use Test::More;

use Catmandu;
use Catmandu::Fix;
use Catmandu::Importer::PICA;
use PICA::Data 'pica_string';

my $fixer = Catmandu::Fix->new(fixes => [
        'pica_map("001B", "date")',
        'pica_map("001U0", "encoding")',
        'pica_map("003.0/1-7", "id")',
        'pica_map("009P[05]a", "url")',
        'pica_map("004Jf0A", "price", -pluck => 1)',
        'remove_field("record")',
        'remove_field("_id")']);
my $importer = Catmandu::Importer::PICA->new(file => "./t/files/picaxml.xml", type=> "XML");
my $records = $fixer->fix($importer)->to_array;

is $records->[0]->{'id'}, '5870077', 'fix id';
is $records->[0]->{'encoding'}, 'utf8', 'fix encoding';
is $records->[0]->{'date'}, '2045:09-04-1318:26:39.000', 'fix date';
is $records->[0]->{'url'}, 'http://ebooks.ciando.com/book/index.cfm/bok_id/43423', 'fix url';
is $records->[0]->{'price'}, '160.45 €36420368139783642036811', 'fix with pluck';

is_deeply $records->[1], {
    id       => '5869538', 
    date     => '1999:22-11-1206:31:01.000', 
    encoding => 'utf8',
    url      => 'http://ebooks.ciando.com/book/index.cfm/bok_id/42632',
    price    => '160.45 €364205076X9783642050763'
}, 'fix record';

## Modify record

sub test_fix {
    my ($fix, $expect) = @_;
    my $fixer = Catmandu::Fix->new( fixes => [$fix] );
    my $importer = Catmandu::Importer::PICA->new( file => "./t/files/minimal.pp", type => "Plain" );
    my $record = $fixer->fix( $importer->first );
    my $result = pica_string($record);
    $result =~ s/\n$//m;
    is $result, $expect, $fix;
}

test_fix('pica_remove(003@)', "021A \$abc\$xyz\n");
test_fix('pica_remove(003@$0)', "021A \$abc\$xyz\n");
test_fix('pica_remove(021A$x)', "003@ \$0123\n021A \$abc\n");
test_fix('pica_remove(021A$xa)', "003@ \$0123\n");

test_fix('pica_keep(003@)', "003@ \$0123\n");
test_fix('pica_keep("003@|021A")', "003@ \$0123\n021A \$abc\$xyz\n");

done_testing;
