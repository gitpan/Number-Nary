package Number::Nary;

use warnings;
use strict;

=head1 NAME

Number::Nary - encode and decode numbers as n-ary strings

=head1 VERSION

version 0.04

 $Id: /my/rjbs/code/nary/trunk/lib/Number/Nary.pm 16007 2005-11-07T13:08:21.179599Z rjbs  $

=cut

our $VERSION = '0.04';

use Carp qw(croak);
use List::MoreUtils qw(all uniq);

use base qw(Exporter);
our @EXPORT = qw(n_codec);
our @EXPORT_OK = qw(n_encode n_decode);

=head1 SYNOPSIS

This module lets you convert numbers into strings that encode the number using
the digit set of your choice.

  my ($encode_sub, $decode_sub) = n_codec('01234'); # base five

  my $number = $encode_sub('8675309'); # jenny's number for one-handed folk

=head1 FUNCTIONS

=head2 C<< n_codec >>

 my ($enc, $dec) = n_codec("123456890"); # we hate seven
 my ($enc, $dec) = n_codec([ qw( foo bar baz ) ]); # metasyntacticary

This routine returns a reference to a subroutine which will encode numbers into
the given set of digits and a reference which will do the reverse operation.

C<$digits> may be a string, which will be split into individual characters, or
an array reference of the digits to be used.

This routine will croak if the digit string contains repeated digits or digits
of non-uniform length.

The encode sub will croak if it is given input other than a non-negative
integer. 

The decode sub will croak if given a string that contains characters not in the
digit string, or if the given string's length is not a multiple of the digit
length.

=cut

sub n_codec {
	my ($base_string) = @_;

  my @digits;
  my $digit_size = 1;
  if (ref $base_string) {
    if (ref $base_string eq 'ARRAY') {
      @digits = @$base_string;
      $digit_size = length $digits[0];
      croak "digits are not of uniform length"
        unless all { length $_ eq $digit_size } @digits;
    } else {
      croak "invalid datatype for base string: "
          . (lc ref $base_string)
          . " reference";
    }
  } else { 
    @digits = split //, $base_string;
  }

  croak "base string contains repeated characters"
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

  my $i = 0;
  my %digit_value = map { $_ => $i++ } @digits;

  my $decode_sub = sub {
    my ($string) = @_;

    croak "string to decode is not a multiple of digit size in length"
      unless (length $string) % $digit_size == 0;

    my @found_digits = $string =~ /(.{$digit_size})/g;
    return 0 unless @found_digits;

    my $value    = 0;
    my $position = 0;
    for my $digit (reverse @found_digits) {
      croak "string to decode contains invalid digits"
        unless exists $digit_value{$digit};
      $value += $digit_value{$digit}  *  @digits ** $position++;
    }
    return $value;
  };

  return ($encode_sub, $decode_sub);
}

=head2 C<< n_encode($value, $digits) >>

This encodes the given value into a string using the given digit string.  It is
written in terms of C<n_codec>, above, so it's not efficient at all for
multiple uses in one process.

This routine is not exported by default.

=head2 C<< n_decode($value, $digits) >>

This is the decoding equivalent to C<n_encode>, above.

This routine is not exported by default.

=cut

sub n_encode { (n_codec($_[1]))[0]->($_[0]) }
sub n_decode { (n_codec($_[1]))[1]->($_[0]) }

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

Copyright 2005 Ricardo Signes, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # my ($encode_sub, $decode_sub) = n_codec('8675309'); # jennynary
