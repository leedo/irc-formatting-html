package IRC::Formatting::HTML::Output;

use warnings;
use strict;

use IRC::Formatting::HTML::Common;

my ($b, $i, $u, $fg, $bg);

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

sub parse {
  my $string = shift;
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

1;
