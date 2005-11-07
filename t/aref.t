use strict;
use warnings;

use Test::More tests => 12;

BEGIN { use_ok('Number::Nary'); }

{
  my ($enc, $dec) = n_codec([qw(X Y Z S V)]);

  my $meaning = $enc->(6 * 9);

  is($meaning, "ZXV", "encodes properly with arrayref of digits");

  my $meaningless = $dec->($meaning);

  is($meaningless, "54", "decodes properly ");

  eval { $enc->(6.2); };
  like($@, qr/integer/, "can't encode floats");

  eval { $enc->("YOUR FACE"); };
  like($@, qr/integer/, "can't encode strings");

  eval { $enc->(-10); };
  like($@, qr/non-negative/, "can't encode negative ints");

  eval { $dec->('BABELFISH'); };
  like($@, qr/invalid/, "can't decode a value with unknown digits");
}

{ # n_encode and n_decode
  is(
    Number::Nary::n_encode(27,["!", "?"]),
    '??!??',
    "27 into interrobanginary-A"
  );

  is(
    Number::Nary::n_decode('??!??',["!", "?"]),
    27,
    "27 from interrobanginary-A"
  );

}

eval { n_codec([qw(X Y Z Z Y)]); };
like($@, qr/repeated/, "you can't build codec with non-unique base string");

eval { n_codec([qw(X Y ZZ Y)]); };
like($@, qr/uniform/, "you can't build codec with non-uniform length digits");

eval { n_codec({ a => 1, b => 2}); };
like($@, qr/hash reference/, "croaks on non-array reference");
