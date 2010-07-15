#!perl -T

use Test::More;
use IRC::Formatting::HTML::Common qw/html_color_to_irc color_distance
                                     hex_color_to_dec rgb_str_to_dec/;

my $black = hex_color_to_dec("#000");
my $white = hex_color_to_dec("#fff");
my $red   = rgb_str_to_dec("rgb(255, 0, 0)");

is_deeply $red, [255, 0, 0];
is_deeply $black, [0, 0, 0];
is_deeply $white, [255, 255, 255];

is color_distance([100, 100, 100], $black), 173.2;
is color_distance($red, $black), 255;

is html_color_to_irc("#ff0000"), "04";
is html_color_to_irc("rgb(255, 0, 0)"), "04";
is html_color_to_irc("#fff"), "00";
is html_color_to_irc("#ddd"), "15";
is html_color_to_irc("#2B37EC"), "12";

done_testing();
