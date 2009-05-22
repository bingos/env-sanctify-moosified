package Env::Sanctify::Moosified;

use strict;
use warnings;
use vars qw($VERSION);

$VERSION = '1.04';

use Moose;

has env => (
  is      => 'ro',
  isa     => 'HashRef',
  default => sub { { } },
);

has sanctify => (
  is      => 'ro',
  isa     => 'ArrayRef',
  default => sub { [ ] },
);

has _backup => (
  is      => 'ro',
  isa     => 'HashRef',
  default => sub { { } },
);

has _restored => (
  is      => 'rw',
  isa	  => 'Bool',
  default => 0,
);

sub sanctify {
  my $self = shift->new( @_ );
  $self->_sanctify;
  return $self;
}

sub _sanctify {
  my $self = shift;
  foreach my $regex ( @{ $self->sanctify } ) { 
    $self->_backup->{$_} = delete $ENV{$_} for grep { eval { /$regex/ } } keys %ENV;
  }
  $self->_backup->{$_} = delete $ENV{$_} for grep { defined $ENV{$_} } keys %{ $self->env };
  $ENV{$_} = $self->env->{$_} for keys %{ $self->env };
  return 1;
}

sub restore {
  my $self = shift;
  delete $ENV{$_} for keys %{ $self->env };
  $ENV{$_} = $self->_backup->{$_} for keys %{ $self->_backup };
  return $self->_restored(1);
}

sub DEMOLISH {
  my $self = shift;
  $self->restore unless $self->_restored;
}

no Moose;
__PACKAGE__->meta->make_immutable;

'Sanctify yourself, set yourself free';

__END__

=head1 NAME

Env::Sanctify::Moosified - Lexically scoped sanctification of %ENV

=head1 SYNOPSIS

  my $sanctify = Env::Sanctify::Moosified->sanctify( sanctify => [ '^POE' ] );

  # do some stuff, fork some processes etc.

  $sanctify->restore

  { 

    my $sanctify = Env::Sanctify::Moosified->sanctify( env => { POE_TRACE_DEFAULT => 1 } );

    # do some stuff, fork some processes etc.
  }

  # out of scope, %ENV is back to normal

=head1 DESCRIPTION

Env::Sanctify::Moosified is a module that provides lexically scoped manipulation and sanctification of 
C<%ENV>.

You can specify that it alter or add additional environment variables or remove existing ones
according to a list of matching regexen.

You can then either C<restore> the environment back manually or let the object fall out of 
scope, which automagically restores.

Useful for manipulating the environment that forked processes and sub-processes will inherit.

=head1 CONSTRUCTOR

=over

=item C<sanctify>

Creates an Env::Sanctify object. Takes two optional arguments:

  'env', a hashref of env vars to add to %ENV;
  'sanctify', an arrayref of regex pattern strings to match against current %ENV vars;

Any C<%ENV> var that matches a C<sanctify> regex is removed from the resultant C<%ENV>.

=back

=head1 METHODs

=over

=item C<restore>

Explicitly restore the previous C<%ENV>. This is called automagically when the object is C<DESTROY>ed, 
for instance, when it goes out of scope.

=back

=head1 AUTHOR

Chris C<BinGOs> Williams <chris@bingosnet.co.uk>

=head1 LICENSE

Copyright E<copy> Chris Williams

This module may be used, modified, and distributed under the same terms as Perl itself. Please see the license that came with your Perl distribution for details.

=cut
