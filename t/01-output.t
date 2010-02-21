#!perl -T

use Test::More;
use IRC::Formatting::HTML;

my $bold = "\002Bold";
my $html = IRC::Formatting::HTML->formatted_string_to_html($bold);
ok($html eq '<span style="font-weight: bold">Bold</span>');

my $inverse = "\026Inverse";
$html = IRC::Formatting::HTML->formatted_string_to_html($inverse);
ok($html eq '<span style="color: #fff;background-color: #000">Inverse</span>');

my $underline = "\037Underline";
$html = IRC::Formatting::HTML->formatted_string_to_html($underline);
ok($html eq '<span style="text-decoration: underline">Underline</span>');

my $color = "\0033,4Color";
$html = IRC::Formatting::HTML->formatted_string_to_html($color);
ok($html eq '<span style="color: #080;background-color: #f00">Color</span>');

my $everything = "$bold$inverse$underline$color";
$html = IRC::Formatting::HTML->formatted_string_to_html($everything);
ok($html eq '<span style="font-weight: bold">Bold</span><span style="color: #fff;background-color: #000;font-weight: bold">Inverse</span><span style="color: #fff;text-decoration: underline;background-color: #000;font-weight: bold">Underline</span><span style="color: #f00;text-decoration: underline;background-color: #080;font-weight: bold">Color</span>');

my $everything_lines = join "\n", ($bold, $inverse, $underline, $color);
$html = IRC::Formatting::HTML->formatted_string_to_html($everything_lines);
ok($html eq join "\n",
('<span style="font-weight: bold">Bold</span>',
 '<span style="color: #fff;background-color: #000">Inverse</span>',
 '<span style="text-decoration: underline">Underline</span>',
 '<span style="color: #080;background-color: #f00">Color</span>'));

done_testing();
