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
our $cint2000;
our $cpu2006;
our $cint2006;
our $spec_test;
our $build_dir;
our @all_specs2000;
our @all_specs2006;

sub usage
{
  print "Usage: ./specbuild.pl -bench 2000|2006 -ext <all|i386|x64|ppc|O0|O2|O2ofp|O3|O3U|pg|".
         "soft-float|hard-float|<ext>> <benchmark>\n";
  print "       Runs in cpu2000 directory only\n";
  print "       Copy spec.mycfg to cpu2000/config directory first\n";
  exit(1);
}

my $extension;
my $bench;
my @all_execs;

GetOptions(
  "extension=s" => \$extension,
  "bench=s" => \$bench
);

my $cpu_dir;
my $cint_dir;
my $outdir;
my $specname;

if ($bench eq "2000") {
  $cpu_dir = $cpu2000;
  $cint_dir = $cint2000;
  $specname = "spec2000";
  @all_execs = @all_specs2000;
} elsif ($bench eq "2006") {
  $specname = "spec2006";
  $cpu_dir = $cpu2006;
  $cint_dir = $cint2006;
  @all_execs = @all_specs2006;
} else {
  usage();
}

$outdir = "$build_dir/$specname";
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
  system ("rm -rf $cint_dir/*/run/*");

  #my @execs = ("int");
  my @execs = @all_execs;
  @execs = @ARGV if ($#ARGV >= 0);

  my $runspec = system ("$cpu_dir/bin/runspec -c spec.mycfg -e $cfg ".
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

sub copy_execs
{
  my $specname = shift;
  my $cfg = shift;

  foreach my $exec (@all_execs) {
    my $exname = spec_exec_name($specname, $exec);
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
      if (!-e "$outdir/$cfg") {
        system("mkdir -p $outdir/$cfg");
      }
      my $out_exname = $exname;
      if ($exname eq "specrand") {
        $exec =~ /^(\d*)\./;
        my $id = $1;
        $out_exname = "$exname.$id";
      }
      copy("$cint_dir/$exec/exe/$exname\_base.$cfg",
        "$outdir/$cfg/$out_exname")
        or print STDERR "Copy failed from ".
           "$cint_dir/$exec/exe/$exname\_base.$cfg to ".
           "$outdir/$cfg/$exname. Error $!\n";
      chmod 0755, "$outdir/$cfg/$out_exname";
    }
  }
}

my @cfgs;
@cfgs = get_cfgs_from_extension($extension);

foreach my $cfg (@cfgs) {
  build_execs($cfg);
  copy_execs($specname, $cfg);
}
