use strict;
use warnings;
use utf8;
use Test::More;
use Test::Exception;

use Catmandu;
use Catmandu::Fix;
use Catmandu::Importer::PICA;

my $fixer = Catmandu::Fix->new(fixes => [
        'set_hash(new)',
        'set_field(new.id, 1234)',
        'set_field(new.id2, 4321)',
        'set_field(new.id3, 5678)',
        'set_field(new.encoding, utf16)',
        'pica_add(new.id, 003@$a)',
        'pica_add(new.id2, 003@$a)',
        'pica_add(new.id3, 003@$a, force_new:1)',
        'pica_add(new.encoding, 201U[02]0)',
        'pica_map("003@a", "ids", split:1)',
        'pica_map("201U[02]$0", "encoding")',
        'set_array(foo, bar)',
        'pica_set(foo.$first, 101U$0)',
        'pica_set(foo.$first, 201U[03]$0)',
        'pica_map(101U$0, what)',
        'pica_map(201U[03]$0, new_what)',
        'pica_set(foo, "001@$0")',
        'pica_add(foo, 001@$0)',
        'pica_map(001@$0, test)'
]);
my $importer = Catmandu::Importer::PICA->new(file => "./t/files/plain.pica", type=> "plain");
my $records = $fixer->fix($importer)->to_array;

is_deeply $records->[0]->{'ids'}, [ ['1234', '4321'], ['5678'] ], '003@a added';
is $records->[0]->{'encoding'}, 'utf16', '201U0 added';
is $records->[0]->{'what'}, 'bar', '101U$0 set';
is $records->[0]->{'test'}, undef, 'foo is not a string';

my $thrower = Catmandu::Fix->new(fixes => [
        'set_array(foo, bar)',
        'pica_add(foo.$first, 001@0a)'
]);

throws_ok( sub {$thrower->fix($importer)->to_array}, qr/Can't use more than one subfield to add a value/,
      'add more than one subfield caught okay');
      
      
done_testing;
