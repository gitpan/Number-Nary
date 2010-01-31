
use strict;
use warnings;



use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Number::Nary',
                       'DISTNAME' => 'Number-Nary',
                       'AUTHOR' => 'Ricardo Signes <rjbs@cpan.org>',
                       'ABSTRACT' => 'encode and decode numbers as n-ary strings',
                       'EXE_FILES' => [],
                       'VERSION' => '1.100310',
                       'LICENSE' => 'perl',
                       'PREREQ_PM' => {
                                        'Test::More' => 0,
                                        'Scalar::Util' => '0.90',
                                        'English' => 0,
                                        'UDCode' => 0,
                                        'ExtUtils::MakeMaker' => '6.11',
                                        'Sub::Exporter' => 0,
                                        'List::MoreUtils' => '0.09',
                                        'Carp' => 0
                                      }
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



