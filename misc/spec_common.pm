#!/usr/bin/perl -w
use strict;
use warnings;
use Switch;
use config_host;

our %args, our %small_args, our %prepcmd;

sub spec_exec_name {
  my $exec = shift;
  $exec =~ /^\d*\.(.*)$/;
  my $exname = ($1 eq "gcc")?"cc1":$1;
  return $exname;
}

sub spec_args_patsubst
{
  my $all_specs = shift;
  my $spec_cint = shift;
  my $specname = shift;
  my $args = shift;
  my $pat = shift;
  my $rep = shift;
  for my $spec (@$all_specs) {
    my $exname = spec_exec_name($spec);
    my %hargs = %$args;
    my $elem = $hargs{"$specname.$exname"};
    #print "exname = $exname\n";
    if (defined $elem) {
      my @eargs = @$elem;
      my @new_eargs = ();
      #print "starting to iterate over @eargs\n";
      foreach my $earg (@eargs) {
        #print "before, earg = $earg\n";
        #print "pat = $pat\n";
        $earg =~ s/$pat/$spec_cint\/$spec\/data\/$rep\/input/g;
        #print "after, earg = $earg\n";
        push(@new_eargs, $earg);
      }
      $$args{"$specname.$exname"} = \@new_eargs;
    }
  }
}

1;
