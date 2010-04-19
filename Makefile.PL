use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'IRC::Formatting::HTML',
    AUTHOR              => 'Lee Aylward <lee@laylward.com>',
    VERSION_FROM        => 'lib/IRC/Formatting/HTML.pm',
    ABSTRACT_FROM       => 'lib/IRC/Formatting/HTML.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'IRC-Formatting-HTML-*' },
);
