package IRC::Formatting::HTML;

use warnings;
use strict;

use IO::String;
use Any::Moose;
use HTML::Entities;

=head1 NAME

IRC::Formatting::HTML - Convert raw IRC formatting to HTML

=head1 VERSION

Version 0.11

=cut

our $VERSION = '0.11';

my $BOLD      = "\002",
my $COLOR     = "\003";
my $RESET     = "\017";
my $INVERSE   = "\026";
my $UNDERLINE = "\037";

my $COLOR_SEQUENCE    = qr/(\d{1,2})(?:,(\d{1,2}))?/;
my $COLOR_SEQUENCE_NC = qr/\d{1,2}(?:,\d{1,2})?/;
my $FORMAT_SEQUENCE   = qr/(
      $BOLD
    | $COLOR$COLOR_SEQUENCE_NC?  | $RESET
    | $INVERSE
    | $UNDERLINE)
    /x;

my @COLORS = ( qw/fff 000 008 080 f00 800 808 f80
         ff0 0f0 088 0ff 00f f0f 888 ccc/ );

has 'b' => (
  is => 'rw',
  isa => 'Bool',
  default => 0,
);

has 'i' => (
  is => 'rw',
  isa => 'Bool',
  default => 0,
);

has 'u' => (
  is => 'rw',
  isa => 'Bool',
  default => 0,
);

has 'fg' => (
  is => 'rw',
  isa => 'Any',
);

has 'bg' => (
  is => 'rw',
  isa => 'Any',
);

=head1 SYNOPSIS

Convert raw IRC formatting to HTML

    use IRC::Formatting::HTML;

    ...

    my $irctext = "\002\0031,2Iron & Wine";
    my $html = IRC::Formatting::HTML->formatted_string_to_html($irctext);
    print $html

    # the above will print:
    # <span style="font-weight: bold;color: #000; background-color: #008">Iron &amp; Wine</span>

=head1 METHODS

=head2 formatted_string_to_html

IRC::Formatting::HTML->formatted_string_to_html($irctext)

Takes an irc formatted string and returns the HTML version
=cut

sub _parse_formatted_string {
  my $line = shift;
  my @segments;
  my @chunks = ("", split(/$FORMAT_SEQUENCE/, $line));
  my $formatting = IRC::Formatting::HTML->new;
  while (scalar(@chunks)) {
    my $format_sequence = shift(@chunks);
    my $text = shift(@chunks);
    my $new_formatting = $formatting->_accumulate($format_sequence);
    push @segments, [$new_formatting, $text];
  }
  return @segments;
}


sub _dup {
  my $self = shift;
  return bless { %$self }, ref $self;
}

sub _reset {
  my $self = shift;
  $self->b(0);
  $self->i(0);
  $self->u(0);
  $self->fg(undef);
  $self->bg(undef);
}

sub _accumulate {
  my ($self, $format_sequence) = @_;
  if ($format_sequence =~ /$BOLD/) {
    $self->b(!$self->b);
  }
  elsif ($format_sequence =~ /$UNDERLINE/) {
    $self->u(!$self->u);
  }
  elsif ($format_sequence =~ /$INVERSE/) {
    $self->i(!$self->i);
  }
  elsif ($format_sequence =~ /$RESET/) {
    $self->_reset;
  }
  elsif ($format_sequence =~ /$COLOR/) {
    my ($fg, $bg) = $self->_extract_colors_from($format_sequence);
    $self->fg($fg);
    $self->bg($bg);
  }
  return $self->_dup;
}

sub _to_css {
  my $self = shift;
  my @properties;
  my %styles = %{ $self->_css_styles };
  for (keys %styles) {
    push @properties, "$_: $styles{$_}";
  }
  return join ";", @properties;
}

sub _extract_colors_from {
  my ($self, $format_sequence) = @_;
  $format_sequence = substr($format_sequence, 1);
  my ($fg, $bg) = ($format_sequence =~ /$COLOR_SEQUENCE/);
  if (! defined $fg) {
    return undef, undef;
  }
  elsif (! defined $bg) {
    return $fg, $self->bg;
  }
  else {
    return $fg, $bg;
  }
}

sub _css_styles {
  my $self = shift;
  my ($fg, $bg) = $self->i ? ($self->bg || 0, $self->fg || 1) : ($self->fg, $self->bg);
  my $styles = {};
  $styles->{'color'} = '#'.$COLORS[$fg] if defined $fg and $COLORS[$fg];
  $styles->{'background-color'} = '#'.$COLORS[$bg] if defined $bg and $COLORS[$bg];
  $styles->{'font-weight'} = 'bold' if $self->b;
  $styles->{'text-decoration'} = 'underline' if $self->u;
  return $styles;
}

sub formatted_string_to_html {
  my ($class, $string) = @_;
  my @lines;
  for (split "\n", $string) {
    my @formatted_line = _parse_formatted_string($_);
    my $line;
    for (@formatted_line) {
      my $text = encode_entities($_->[1], '<>&"');
      if (defined $text and length $text) {
        $text =~ s/ {2}/ &#160;/g;
        $line .= '<span style="'.$_->[0]->_to_css.'">'.$text.'</span>'; 
      }
    }
    push @lines, $line if length $line;
  }
  return join "\n", @lines;
}

__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

Lee Aylward, E<lt>leedo@cpan.orgE<gt>

=head1 BUGS

Please report any bugs or feature requests to C<bug-irc-formatting-html at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IRC-Formatting-HTML>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IRC::Formatting::HTML


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=IRC-Formatting-HTML>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/IRC-Formatting-HTML>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/IRC-Formatting-HTML>

=item * Search CPAN

L<http://search.cpan.org/dist/IRC-Formatting-HTML/>

=back


=head1 ACKNOWLEDGEMENTS

This is a direct port of Sam Stephenson's ruby version.


=head1 COPYRIGHT & LICENSE

Copyright 2009 Lee Aylward, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of IRC::Formatting::HTML
