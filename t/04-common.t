#!perl -T

use Test::More;
use IRC::Formatting::HTML::Common qw/html_color_to_irc color_distance
                                     hex_color_to_dec/;

my $black = hex_color_to_dec("#000");
my $white = hex_color_to_dec("#fff");

is_deeply $black, [0, 0, 0];
is_deeply $white, [255, 255, 255];

is html_color_to_irc("#ff0000"), "04";
is html_color_to_irc("#fff"), "00";
is html_color_to_irc("#ddd"), "15";
is html_color_to_irc("#2B37EC"), "12";

done_testing();