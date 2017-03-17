#!/usr/bin/perl -w
use strict;
use warnings;
use Switch;
use config_host;

our %args, our %small_args, our %prep_commands;

sub spec_exec_name {
  my $specname = shift;
  my $exec = shift;
  $exec =~ /^(\d*)\.(.*)$/;
  my $id = $1;
  my $name = $2;
  my $exname;
  #if ($name eq "specrand" && $specname eq "spec2006") {
  #  $exname = "$name.$id";
  #} else {
    $exname = ($name eq "gcc" && $specname eq "spec2000")?"cc1":$name;
  #}

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
    my $exname = spec_exec_name($specname, $spec);
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
