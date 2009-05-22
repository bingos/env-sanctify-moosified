use strict;
use warnings;
use Env::Sanctify::Moosified;

my $sanctified = { PATH => $ENV{PATH} };

{ 
  my $sanctify = Env::Sanctify::Moosified->sanctify( env => $sanctified, sanctify => [ '.*' ] );

  system("$^X " . '-MData::Dumper -e \'warn Dumper(\%ENV);\'');
}
