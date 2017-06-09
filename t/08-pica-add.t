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
        'set_array(foo, bar, baz)',
        'pica_set(foo.$first, 101U$0)',
        'pica_map(101U$0, what)',
        'pica_add(foo, 001@$01)',
        'pica_map(001@$01, multi)'
]);
my $importer = Catmandu::Importer::PICA->new(file => "./t/files/plain.pica", type=> "plain");
my $records = $fixer->fix($importer)->to_array;

is_deeply $records->[0]->{'ids'}, [ ['1234', '4321'], ['5678'] ], '003@a added';
is $records->[0]->{'encoding'}, 'utf16', '201U0 added';
is $records->[0]->{'what'}, 'bar', '101U$0 set';
is $records->[0]->{'multi'}, 'barbaz', 'added multiple subfields to 001@';

my $thrower = Catmandu::Fix->new(fixes => [
        'set_array(foo, bar)',
        'pica_add(foo.$first, 001@)'
]);

throws_ok( sub {$thrower->fix($importer)->to_array}, qr/At least one subfield is required for pica_add to field/,
      'add more than one subfield caught okay');
      
      
done_testing;
