use strict;
use warnings;

use Test::More tests => 14;

BEGIN { use_ok('Number::Nary'); }

{
  my ($enc, $dec) = n_codec([qw(XY ZZ Y!)]);

  my $meaning = $enc->(6 * 9);

  is($meaning, "Y!XYXYXY", "encodes properly with arrayref of strings");

  my $meaningless = $dec->($meaning);

  is($meaningless, "54", "decodes properly ");

  eval { $enc->(6.2); };
  like($@, qr/integer/, "can't encode floats");

  eval { $enc->("YOUR FACE"); };
  like($@, qr/integer/, "can't encode strings");

  eval { $enc->(-10); };
  like($@, qr/non-negative/, "can't encode negative ints");

  eval { $dec->('BABELFISH'); };
  like($@, qr/digit size in length/, "can't decode a string of invalid length");

  eval { $dec->('SHLOMIFISH'); };
  like($@, qr/invalid/, "can't decode a string with invalid digits");
}

{ # n_encode and n_decode
  my $digits = [ qw(!! !? ?? ?!) ];
  is(
    Number::Nary::n_encode(27, $digits),
    '!????!',
    "27 into interrobanginary-B",
  );

  is(
    Number::Nary::n_decode('!????!', $digits),
    27,
    "27 from interrobanginary-B",
  );

}

{ # jaencode!
  my @kana = qw(
    ka ki ku ke ko ta te to sa su se so na ni nu ne no ha
    hi fu he ho ma mi mu me mo ya yu yo ra ri ru re ro wa
    wo 
  );

  is(
    Number::Nary::n_encode(102391022, \@kana),
    'kihaminehero',
    'nary can now replace my old "jaencode" script',
  );

  is(
    Number::Nary::n_decode('kihaminehero', \@kana),
    102391022,
    'and it even decodes!',
  );
}

eval { n_codec([qw(X Y Z Z Y)]); };
like($@, qr/repeated/, "you can't build codec with non-unique base string");

eval { n_codec([qw(X Y ZZ Y)]); };
like($@, qr/uniform/, "you can't build codec with non-uniform length digits");
