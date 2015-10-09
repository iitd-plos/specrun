#!/usr/bin/perl -w
use strict;
use warnings;
use POSIX;
use POSIX ":sys_wait_h";
use POSIX qw(setsid);
use POSIX qw(:errno_h :fcntl_h);
use Switch;
use File::Find;
use File::Copy;
use Getopt::Long;
use config_host;
#use Sub::Curry;

use myutils;
use benchmarks;

#our $superopt_build;
our $spec_ref;
our $cpu2000;
our $spec_test;
our $build_dir;

sub usage
{
  print "Usage: ./specbuild.pl -ext <all|i386|ppc|O0|O2|O2ofp|O3|O3f|pg|".
         "soft-float|hard-float|<ext>> <benchmark>\n";
  print "       Runs in cpu2000 directory only\n";
  print "       Copy spec.mycfg to cpu2000/config directory first\n";
  exit(1);
}

my $extension;
GetOptions(
  "extension=s" => \$extension
);

$extension = "all" if (!$extension);

sub search_suffix
{
  my $suffix = shift;
  my $filename = shift;

  print "suffix=$suffix\n";
  print "filename=$filename\n";
  print $filename if ($filename =~ /$suffix$/);
}

sub build_execs
{
  my $cfg = shift;
  system ("rm -rf benchspec/CINT2000/*/run/*");

  my @execs = ("int");
  @execs = @ARGV if ($#ARGV >= 0);

  my $runspec = system ("$cpu2000/bin/runspec -c spec.mycfg -e $cfg ".
    "-I --rebuild --iterations=0 --loose @execs");

  if ($runspec == -1) {
    print "system() command failed.\n";
    exit(1);
  }
  if (WIFSIGNALED($runspec)) {
    print "\nrunspec received signal ";
    switch (WTERMSIG($runspec)) {
      case SIGINT		{ print "SIGINT" }
      case SIGSEGV		{ print "SIGSEGV" }
    }
    print ". exiting\n";
    exit(1);
  }
  if (WIFEXITED($runspec)) {
    if (WEXITSTATUS($runspec) != 0) {
      printf("Translation exited with status %d. exiting\n", WEXITSTATUS($runspec));
      exit(1);
    }
  }

  #my $search_cfg = Sub::curry (&search_suffix, "_base.$cfg");
  #find($search_cfg, "$cpu2000/benchspec/CINT2000/");

  #system ("find $cpu2000/benchspec/CINT2000 -name \"*/exe/*_base.$cfg\"");
}

our @all_specs;
my @all_execs = @all_specs;

sub copy_execs
{
  my $cfg = shift;

  foreach my $exec (@all_execs) {
    my $exname = spec_exec_name($exec);
    my $consider_exec;
    if ($#ARGV >= 0) {
      $consider_exec = 0;
      foreach my $arg (@ARGV) {
        if ($arg eq $exname) { $consider_exec = 1;}
      }
    } else {
      $consider_exec = 1;
    }

    if ($consider_exec) {
      my $outdir = "$build_dir/specs";
      if (!-e "$outdir/$cfg") {
        system("mkdir -p $outdir/$cfg");
      }
      copy("$cpu2000/benchspec/CINT2000/$exec/exe/$exname\_base.$cfg",
        "$outdir/$cfg/$exname")
        or print STDERR "Copy failed from ".
           "$cpu2000/benchspec/CINT2000/$exec/exe/$exname\_base.$cfg to ".
           "$outdir/$cfg/$exname. Error $!\n";
      chmod 0755, "$outdir/$cfg/$exname";
    }
  }
}

my @cfgs;
my @soft_float = ("i386-O2-soft-float", "i386-O0-soft-float", "ppc-O0-soft-float",
  "ppc-O2-soft-float");
my @hard_float = ("i386-O2-hard-float", "i386-O0-hard-float", "ppc-O0-hard-float",
  "ppc-O2-hard-float");

switch ($extension) {
  case "all" {@cfgs = ("i386-O0", "i386-O2", "i386-O3", "i386-O3f",
      "ppc-O0", "ppc-O2", "ppc-O3", "ppc-O3f");}
  #"ppc-O0", "ppc-O2", "ppc-O3", "ppc-O3f", @soft_float, @hard_float);
  case "i386" {@cfgs = ("clang-i386-O0", "clang-i386-O2", "clang-i386-O2U", "icc-i386-O0", "icc-i386-O2", "icc-i386-O2U", "i386-O0", "i386-O2", "i386-O2U", "i386-O3", "i386-O3f");}
  #case "i386" {@cfgs = ("i386-O0", "i386-O2", "i386-O3", "i386-O3f", "i386-O2-soft-float",
  #    "i386-O0-soft-float", "i386-O2-hard-float", "i386-O0-hard-float");}
  case "ppc" {@cfgs = ("ppc-O0", "ppc-O2", "ppc-O3", "ppc-O3f");}
  case "O0" {@cfgs = ("i386-O0", "ppc-O0");}
  case "O2" {@cfgs = ("i386-O2", "ppc-O2");}
  case "O2ofp" {@cfgs = ("i386-O2ofp");}
  case "O3" {@cfgs = ("i386-O3", "ppc-O3");}
  case "O3f" {@cfgs = ("i386-O3f", "ppc-O3f");}
  case "pg" {@cfgs = ("i386-O0-pg", "i386-O2-pg", "ppc-O0-pg", "ppc-O2-pg");}
  case "soft-float" {@cfgs = @soft_float;}
  case "hard-float" {@cfgs = @hard_float;}
  else { print "extension $extension\n"; @cfgs = ("$extension"); }
}


foreach my $cfg (@cfgs) {
  build_execs($cfg);
  copy_execs($cfg);
}
