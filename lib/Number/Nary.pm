package Number::Nary;

use warnings;
use strict;

=head1 NAME

Number::Nary - encode and decode numbers as n-ary strings

=head1 VERSION

version 0.102

 $Id: /my/cs/projects/Number-Nary/trunk/lib/Number/Nary.pm 29659 2007-01-03T23:09:59.377348Z rjbs  $

=cut

our $VERSION = '0.102';

use Carp qw(croak);
use List::MoreUtils qw(uniq);

use Sub::Exporter -setup => {
  exports => [ qw(n_codec n_encode n_decode) ],
  groups  => {
    default    => [ qw(n_codec) ],
    codec_pair => \&_generate_codec_pair,
  }
};

sub _generate_codec_pair {
  my (undef, undef, $arg, undef) = @_;

  my $local_arg = {%$arg};
  my $digits    = delete $local_arg->{digits};

  my %pair;
  @pair{qw(encode decode)} = n_codec($digits, $local_arg);
  return \%pair;
}

=head1 SYNOPSIS

This module lets you convert numbers into strings that encode the number using
the digit set of your choice.  For example, you could get routines to convert
to and from hex like so:

  my ($enc_hex, $dec_hex) = n_codec('0123456789ABCDEF');

  my $hex = $enc_hex(255);  # sets $hex to FF
  my $num = $dec_hex('A0'); # sets $num to 160

This would be slow and stupid, since Perl already provides the means to easily
and quickly convert between decimal and hex representations of numbers.
Number::Nary's utility comes from the fact that it can encode into bases
composed of arbitrary digit sets.

  my ($enc, $dec) = n_codec('0123'); # base 4 (for working with nybbles?)

  # base64
  my ($enc, $dec) = n_codec(
    join('', 'A' .. 'Z', 'a' .. 'z', 0 .. 9, '+', '/', '=')
  );

=head1 FUNCTIONS

=head2 n_codec

  my ($encode_sub, $decode_sub) = n_codec($digit_string, \%arg);

This routine returns a reference to a subroutine which will encode numbers into
the given set of digits and a reference which will do the reverse operation.

The digits may be given as a string or an arrayref.  This routine will croak if
the set of digits contains repeated digits, or if not all digits are of the
same length of characters.

The encode sub will croak if it is given input other than a non-negative
integer. 

The decode sub will croak if given a string that contains characters not in the
digit string, or if the lenth of the string to decode is not a multiple of the
length of the component digits.

Valid arguments to be passed in the second parameter are:

  predecode  - if given, this coderef will be used to preprocess strings
               passed to the decoder

=cut

sub n_codec {
	my ($base_string, $arg) = @_;

	my @digits;
  my $length = 1;
  if (eval { @digits = @$base_string; 1 }) {
    my @lengths = uniq map { length } @digits;
    croak "given digits were not of uniform length" unless @lengths == 1;
    $length = length $digits[0];
  } else {
    @digits = split //, $base_string;
  }

  croak "digit list contains repeated characters"
    unless @digits == uniq @digits;

  my $encode_sub = sub {
    my ($value) = @_;

    croak "value isn't an non-negative integer"
      if not defined $value
      or $value !~ /\A\d+\z/;

      my $string = '';
      while (1) {
        my $digit = $value % @digits;
        $value = int($value / @digits);
        $string = "$digits[$digit]$string";
        last unless $value;
      }
    return $string;
  };

  my %digit_value = do { my $i = 0; map { $_ => $i++ } @digits; };

  my $decode_sub = sub {
    my ($string) = @_;
    return unless $string;
    
    $string = $arg->{predecode}->($string) if $arg->{predecode};

    my $places = length($string) / $length;

    croak "string length is not a multiple of digit length"
      unless $places == int $places;

    my $value    = 0;

    for my $position (reverse 1 .. $places) {
      my $digit = substr $string, (-$length * $position), $length;
      croak "string to decode contains invalid digits"
        unless exists $digit_value{$digit};
      $value += $digit_value{$digit}  *  @digits ** ($position++ - 1);
    }
    return $value;
  };

  return ($encode_sub, $decode_sub);
}

=head2 n_encode

  my $string = n_encode($value, $digit_string);

This encodes the given value into a string using the given digit string.  It is
written in terms of C<n_codec>, above, so it's not efficient at all for
multiple uses in one process.

=head2 n_decode

  my $number = n_decode($string, $digit_string);

This is the decoding equivalent to C<n_encode>, above.

=cut

# If you really can't stand using n_codec, you could memoize these.
sub n_encode { (n_codec($_[1]))[0]->($_[0]) }
sub n_decode { (n_codec($_[1]))[1]->($_[0]) }

=head1 EXPORTS

C<n_codec> is exported by default.  C<n_encode> and C<n_decode> are exported.

Pairs of routines to encode and decode may be imported by using the
C<codec_pair> group as follows:

  use Number::Nary -codec_pair => { digits => '01234567', -suffix => '8' };

  my $encoded = encode8($number);
  my $decoded = decode8($encoded);

For more information on this kind of exporting, see L<Sub::Exporter>.

=head1 AUTHOR

Ricardo Signes, C<< <rjbs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-number-nary@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Number-Nary>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SECRET ORIGINS

I originally used this system to produce unique worksheet names in Excel.  I
had a large report generating system that used Win32::OLE, and to keep track of
what was where I'd Storable-digest the options used to produce each worksheet
and then n-ary encode them into the set of characters that were valid in
worksheet names.  Working out that set of characters was by far the hardest
part.

=head1 ACKNOWLEDGEMENTS

Thanks, Jesse Vincent.  When I remarked, on IRC, that this would be trivial to
do, he said, "Great.  Would you mind doing it?"  (Well, more or less.)  It was
a fun little distraction.

=head1 COPYRIGHT & LICENSE

Copyright 2005-2006 Ricardo Signes, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # my ($encode_sub, $decode_sub) = n_codec('8675309'); # jennynary
