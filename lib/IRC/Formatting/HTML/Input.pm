package IRC::Formatting::HTML::Input;

use warnings;
use strict;

use IRC::Formatting::HTML::Common;
use HTML::Parser ();

my $p = HTML::Parser->new(api_version => 3,
            text_h  => [\&_text, 'dtext'],
            start_h => [\&_tag_start, 'tagname'],
            end_h   => [\&_tag_end, 'tagname']);

my $nbsp = chr(160);
my ($b, $i, $u, $fg, $bg);
my $irctext = "";

sub parse {
  $irctext = "";
  _reset();
  $p->parse(shift);
  $p->eof;
  return $irctext;
}

sub _reset {
  ($b, $i, $u) = (0, 0, 0);
  undef $fg;
  undef $bg;
}

sub _text {
  my $text = shift;
  $text =~ s/$nbsp/ /g;
  $irctext .= $text if defined $text and length $text;
}

sub _tag_start {
  my $tag = shift;

  if ($tag eq "strong" or $tag eq "b") {
    $irctext .= $BOLD unless $b;
    $b = 1;
  } elsif ($tag eq "em" or $tag eq "i") {
    $irctext .= $INVERSE unless $i;
    $i = 1;
  } elsif ($tag eq "u") {
    $irctext .= $UNDERLINE unless $u;
    $u = 1;
  }
  elsif ($tag eq "br" or $tag eq "p" or $tag eq "div") {
    $irctext .= "\n";
  }
}

sub _tag_end {
  my $tag = shift;

  if ($tag eq "strong" or $tag eq "b") {
    $irctext .= $BOLD if $b;
    $b = 0;
  } elsif ($tag eq "em" or $tag eq "i") {
    $irctext .= $INVERSE if $i;
    $i = 0;
  } elsif ($tag eq "u") {
    $irctext .= $UNDERLINE if $u;
    $u = 0;
  }
}

1
