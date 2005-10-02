use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Number::Nary',
    AUTHOR              => 'Ricardo Signes <rjbs@cpan.org>',
    VERSION_FROM        => 'lib/Number/Nary.pm',
    ABSTRACT_FROM       => 'lib/Number/Nary.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Number-Nary-*' },
);
