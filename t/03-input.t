#!perl -T

use Test::More;
use IRC::Formatting::HTML qw/html_to_irc/;
use IRC::Formatting::HTML::Common;

my $nohtml = "No html here";
my $irc = html_to_irc($nohtml);
is($irc, $nohtml);

my $newline = "first line<div>second line</div>";
$irc = html_to_irc($newline);
is ($irc, "first line\nsecond line");

my $bold = "<b>Bold</b>notbold";
$irc = html_to_irc($bold);
is($irc, $BOLD."Bold".$BOLD."notbold");

my $bolditalic = "<b><i>Hjalp</i></b>";
$irc = html_to_irc($bolditalic);
is($irc, $BOLD.$INVERSE."Hjalp".$INVERSE.$BOLD);

my $inverse = "<i>Inverse</i>";
$irc = html_to_irc($inverse);
is($irc, $INVERSE."Inverse".$INVERSE);

my $underline = "<u>Underline</u>";
$irc = html_to_irc($underline);
is($irc, $UNDERLINE."Underline".$UNDERLINE);

my $combo = "<b>Combo <i>formatting</i></b>";
$irc = html_to_irc($combo);
is($irc, $BOLD."Combo ".$INVERSE."formatting".$INVERSE.$BOLD);

my $everything = "<b><i><u>Everything</u></i></b>";
$irc = html_to_irc($everything);
is($irc, $BOLD.$INVERSE.$UNDERLINE."Everything".$UNDERLINE.$INVERSE.$BOLD);

my $nbsp = "&nbsp;<b>some text</b>";
$irc = html_to_irc($nbsp);
is($irc, " ".$BOLD."some text".$BOLD);

my $colored = "<span style='color:#ddd'>some <span style='color:#fff'>text</span></span> heh";
$irc = html_to_irc($colored);
is($irc, $COLOR."15some ".$COLOR."00text".$COLOR."15$COLOR heh");

my $false_char = "0 hello";
$irc = html_to_irc($false_char);
is ($irc, "0 hello");

done_testing();
