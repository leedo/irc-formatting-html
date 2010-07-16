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
my @states;
my $irctext = "";

sub parse {
  $irctext = "";
  _reset();
  my $html = shift;
  $html =~ s/\n//;
  $p->parse($html);
  $p->eof;
  $irctext =~ s/^\n+//;
  $irctext =~ s/\n+$//;
  return $irctext;
}

sub _reset {
  @states = ({
    b => 0,
    i => 0,
    u => 0,
    fg => "",
    bg => "",
  });
}

sub _text {
  my $text = shift;
  $text =~ s/$nbsp/ /g;
  $irctext .= $text if defined $text and length $text;
}

sub clone {
  my $state = $states[0];
  return {
    b => $state->{b},
    i => $state->{i},
    u => $state->{u},
    fg => $state->{fg},
    bg => $state->{bg},
  };
}

sub _tag_start {
  my ($tag, $attr) = @_;

  my $state = clone();

  if ($tag eq "br" or $tag eq "p" or $tag eq "div" or $tag =~ /^h[\dr]$/) {
    $irctext .= "\n";
  }

  if ($attr->{style}) {
    if ($attr->{style} =~ /(?:^|;\s*)color:\s*([^;"]+)/) {
      my $color = IRC::Formatting::HTML::Common::html_color_to_irc($1);
      if ($color) {
        $state->{fg} = $color;
        $irctext .= $COLOR.$color;
      }
    }
    if ($attr->{style} =~ /font-weight:\s*bold/) {
      $irctext .= $BOLD unless $state->{b};
      $state->{b} = 1;
    }
    if ($attr->{style} =~ /font-style:\s*italic/) {
      $irctext .= $INVERSE unless $state->{i};
      $state->{i} = 1;
    }
    if ($attr->{style} =~ /text-decoration:\s*underline/) {
      $irctext .= $UNDERLINE unless $state->{u};
      $state->{u} = 1;
    }
    if ($attr->{style} =~ /background-color:\s*([^;"]+)/) {
      my $color = IRC::Formatting::HTML::Common::html_color_to_irc($1);
      if ($color) {
        $state->{bg} = $color;
        $irctext .= $COLOR.$color;
      }

    }
  }

  if ($tag eq "strong" or $tag eq "b" or $tag =~ /^h\d$/) {
    $irctext .= $BOLD unless $state->{b};
    $state->{b} = 1;
  } elsif ($tag eq "em" or $tag eq "i") {
    $irctext .= $INVERSE unless $state->{i};
    $state->{i} = 1;
  } elsif ($tag eq "u") {
    $irctext .= $UNDERLINE unless $state->{u};
    $state->{u} = 1;
  }

  unshift @states, $state;
}

sub _tag_end {
  my $tag = shift;

  my $prev = shift @states;
  my $next = $states[0];

  if ($tag eq "p" or $tag eq "div" or $tag =~ /^h[\dr]$/) {
    $irctext .= "\n";
  }

  $irctext .= $BOLD if $next->{b} ne $prev->{b};
  $irctext .= $INVERSE if $next->{i} ne $prev->{i};
  $irctext .= $UNDERLINE if $next->{u} ne $prev->{u};
  $irctext .= $COLOR.$next->{fg} if $next->{fg} ne $prev->{fg};
  $irctext .= $COLOR.$next->{bg} if $next->{bg} ne $prev->{bg};
}

1
