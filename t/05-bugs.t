#!perl -T

use Test::More;
use IRC::Formatting::HTML qw/irc_to_html html_to_irc/;
use IRC::Formatting::HTML::Common;

my $broken = "\0\x{ff17}\x{ff18}";
my $html = irc_to_html($broken);

is $html, '<span style="">'.$broken.'</span>';

my $broken_color = 'asdf <font color="#FF00FF"><b>asdf </b><font color="#00000000">asdf</font></font>';
my $html = html_to_irc($broken_color);
my $expect = "asdf ".$COLOR."13".$BOLD."asdf ".$BOLD.$COLOR."asdf";

is $html, $expect;

done_testing();
