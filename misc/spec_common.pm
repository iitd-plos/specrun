#!/usr/bin/perl -w
use strict;
use warnings;
use Switch;
use config_host;

sub spec_exec_name {
  my $exec = shift;
  $exec =~ /^\d*\.(.*)$/;
  my $exname = ($1 eq "gcc")?"cc1":$1;
  return $exname;
}

1;
