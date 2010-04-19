#!perl -T

use Test::More;
use IRC::Formatting::HTML;

my $empty = "";
my $html = IRC::Formatting::HTML->formatted_string_to_html($empty);
ok($html eq "");

my $zero = "0";
$html = IRC::Formatting::HTML->formatted_string_to_html($zero);
ok($html eq '<span style="">0</span>');

done_testing();
