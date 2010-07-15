package IRC::Formatting::HTML::Input;

use warnings;
use strict;

use IRC::Formatting::HTML::Common;
use HTML::Parser ();

my $p = HTML::Parser->new(api_version => 3,
            text_h  => [\&_text, 'dtext'],
            start_h => [\&_tag_start, 'tagname, attr'],
            end_h   => [\&_tag_end, 'tagname']);

my $nbsp = chr(160);
my ($b, $i, $u, @fg, @bg);
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
  @fg = ();
  @bg = ();
}

sub _text {
  my $text = shift;
  $text =~ s/$nbsp/ /g;
  $irctext .= $text if defined $text and length $text;
}

sub _tag_start {
  my ($tag, $attr) = @_;

  my $fg = $fg[0];

  if ($attr->{style} and $attr->{style} =~ /(?:^|;\s*)color:\s*([^;"]+)/) {
    my $color = IRC::Formatting::HTML::Common::html_color_to_irc($1);
    if ($color) {
      $fg = $color;
      $irctext .= $COLOR.$fg;
    }
  }
  push @fg, $fg;

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
  my ($tag, $attr) = @_;

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

  my $fg = pop @fg;
  $fg = "" unless defined $fg;

  my $next = $fg[0];
  $next = "" unless defined $next;

  if ($fg ne $next) {
    $irctext .= $COLOR.$next;
  }
}

1
