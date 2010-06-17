package IRC::Formatting::HTML::Common;

use warnings;
use strict;

use Exporter 'import';

our @EXPORT = qw/$BOLD $COLORM $RESET $INVERSE $UNDERLINE
                $COLOR_SEQUENCE $FORMAT_SEQUENCE @COLORS/;

our $BOLD      = "\002",
our $COLOR     = "\003";
our $COLORM    = qr/^$COLOR/;
our $RESET     = "\017";
our $INVERSE   = "\026";
our $UNDERLINE = "\037";

our $COLOR_SEQUENCE    = qr/(\d{1,2})(?:,(\d{1,2}))?/;
my $COLOR_SEQUENCE_NC = qr/\d{1,2}(?:,\d{1,2})?/;
our $FORMAT_SEQUENCE   = qr/(
      $BOLD
    | $COLOR$COLOR_SEQUENCE_NC?  | $RESET
    | $INVERSE
    | $UNDERLINE)
    /x;

our @COLORS = ( qw/fff 000 008 080 f00 800 808 f80
                   ff0 0f0 088 0ff 00f f0f 888 ccc/ );

1;
