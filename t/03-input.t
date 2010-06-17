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

my $bold = "<strong>Bold</strong>";
$irc = html_to_irc($bold);
is($irc, $BOLD."Bold".$BOLD);

my $inverse = "<em>Inverse</em>";
$irc = html_to_irc($inverse);
is($irc, $INVERSE."Inverse".$INVERSE);

my $underline = "<u>Underline</u>";
$irc = html_to_irc($underline);
is($irc, $UNDERLINE."Underline".$UNDERLINE);

my $combo = "<strong>Combo <em>formatting</em></strong>";
$irc = html_to_irc($combo);
is($irc, $BOLD."Combo ".$INVERSE."formatting".$INVERSE.$BOLD);

my $everything = "<strong><em><u>Everything</u></em></strong>";
$irc = html_to_irc($everything);
is($irc, $BOLD.$INVERSE.$UNDERLINE."Everything".$UNDERLINE.$INVERSE.$BOLD);

done_testing();
