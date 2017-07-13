on 'test', sub {
  requires 'Test::More', '1.001003';
  requires 'Test::Exception', '0.43';
  requires 'File::Temp' , '0.2304';
  requires 'IO::File' , '1.14';
  requires 'Test::XML' , '0.08';
};

requires 'perl', '5.10.0';
requires 'Catmandu', '1.0601';
requires 'PICA::Data', '0.33';
requires 'PICA::Parser', '0.585';
requires 'Moo', '1.0';

# To get PICA via SRU
recommends 'Catmandu::SRU', '>= 0.032';
conflicts 'Catmandu::SRU', '< 0.032';
