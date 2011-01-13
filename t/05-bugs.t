#!perl -T

use Test::More;
use IRC::Formatting::HTML qw/irc_to_html/;

my $broken = "\0\x{ff17}\x{ff18}";
my $html = irc_to_html($broken);

is $html, '<span style="">'.$broken.'</span>';

done_testing();
