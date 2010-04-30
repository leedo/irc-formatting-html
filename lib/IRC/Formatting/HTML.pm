package IRC::Formatting::HTML;

use warnings;
use strict;

use Exporter 'import';

=head1 NAME

IRC::Formatting::HTML - Convert raw IRC formatting to HTML

=head1 VERSION

Version 0.18

=cut

our @EXPORT_OK = qw/irc_to_html/;
our $VERSION = '0.18';

my $BOLD      = "\002",
my $COLOR     = "\003";
my $COLORM    = qr/^$COLOR/;
my $RESET     = "\017";
my $INVERSE   = "\026";
my $UNDERLINE = "\037";

my $COLOR_SEQUENCE    = qr/(\d{1,2})(?:,(\d{1,2}))?/;
my $COLOR_SEQUENCE_NC = qr/\d{1,2}(?:,\d{1,2})?/;
my $FORMAT_SEQUENCE   = qr/(
      $BOLD
    | $COLOR$COLOR_SEQUENCE_NC?  | $RESET
    | $INVERSE
    | $UNDERLINE)
    /x;

my @COLORS = ( qw/fff 000 008 080 f00 800 808 f80
         ff0 0f0 088 0ff 00f f0f 888 ccc/ );

my ($b, $i, $u, $fg, $bg);

=head1 SYNOPSIS

Convert raw IRC formatting to HTML

    use IRC::Formatting::HTML qw/irc_to_html/;

    ...

    my $irctext = "\002\0031,2Iron & Wine";
    my $html = irc_to_html($irctext);
    print $html

    # the above will print:
    # <span style="font-weight: bold;color: #000; background-color: #008">Iron &amp; Wine</span>

=head1 FUNCTIONS

=head2 irc_to_html

irc_to_html($irctext)

Takes an irc formatted string and returns the HTML version
=cut

sub _parse_formatted_string {
  my $line = shift;
  _reset();
  my @segments;
  my @chunks = ("", split($FORMAT_SEQUENCE, $line));
  $line = "";
  while (scalar(@chunks)) {
    my $format_sequence = shift(@chunks);
    my $text = shift(@chunks);
    next unless defined $text and length $text;
    _accumulate($format_sequence);
    $text =~ s/ {2}/ &#160;/g;
    $line .= "<span style=\""._to_css()."\">$text</span>"; 
  }
  return $line;
}


sub _reset {
  ($b, $i, $u) = (0, 0, 0);
  undef $fg;
  undef $bg;
}

sub _accumulate {
  my $format_sequence = shift;
  if ($format_sequence eq $BOLD) {
    $b = !$b;
  }
  elsif ($format_sequence eq $UNDERLINE) {
    $u = !$u;
  }
  elsif ($format_sequence eq $INVERSE) {
    $i = !$i;
  }
  elsif ($format_sequence eq $RESET) {
    _reset;
  }
  elsif ($format_sequence =~ $COLORM) {
    ($fg, $bg) = _extract_colors_from($format_sequence);
  }
}

sub _to_css {
  my @properties;
  my %styles = %{ _css_styles() };
  for (keys %styles) {
    push @properties, "$_: $styles{$_}";
  }
  return join ";", @properties;
}

sub _extract_colors_from {
  my $format_sequence = shift;
  $format_sequence = substr($format_sequence, 1);
  my ($_fg, $_bg) = ($format_sequence =~ $COLOR_SEQUENCE);
  if (! defined $_fg) {
    return undef, undef;
  }
  elsif (! defined $_bg) {
    return $_fg, $bg;
  }
  else {
    return $_fg, $_bg;
  }
}

sub _css_styles {
  my ($_fg, $_bg) = $i ? ($bg || 0, $fg || 1) : ($fg, $bg);
  my $styles = {};
  $styles->{'color'} = '#'.$COLORS[$_fg] if defined $_fg and $COLORS[$_fg];
  $styles->{'background-color'} = '#'.$COLORS[$_bg] if defined $_bg and $COLORS[$_bg];
  $styles->{'font-weight'} = 'bold' if $b;
  $styles->{'text-decoration'} = 'underline' if $u;
  return $styles;
}

sub irc_to_html {
  my $string = shift;
  return __PACKAGE__->formatted_string_to_html($string);
}

sub formatted_string_to_html {
  my ($class, $string) = @_;
  join "\n",
       map {_parse_formatted_string($_)}
       split "\n", _encode_entities($string);
}

sub _encode_entities {
  my $string = shift;
  return $string unless $string;
  $string =~ s/&/&amp;/g;
  $string =~ s/</&lt;/g;
  $string =~ s/>/&gt;/g;
  $string =~ s/"/&quot;/g;
  return $string;
}

=head1 AUTHOR

Lee Aylward, E<lt>leedo@cpan.orgE<gt>

=head1 BUGS

Please report any bugs or feature requests to C<bug-irc-formatting-html at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IRC-Formatting-HTML>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IRC::Formatting::HTML


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=IRC-Formatting-HTML>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/IRC-Formatting-HTML>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/IRC-Formatting-HTML>

=item * Search CPAN

L<http://search.cpan.org/dist/IRC-Formatting-HTML/>

=back


=head1 ACKNOWLEDGEMENTS

This is a direct port of Sam Stephenson's ruby version.


=head1 COPYRIGHT & LICENSE

Copyright 2009 Lee Aylward, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of IRC::Formatting::HTML
