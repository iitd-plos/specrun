#!/usr/bin/perl -w

use Time::HiRes qw( usleep ualarm gettimeofday tv_interval );
use POSIX;
use POSIX ":sys_wait_h";
use POSIX qw(setsid);
use POSIX qw(:errno_h :fcntl_h);
use Switch;
use Getopt::Long;
use Unix::Mknod qw(:all);
use File::Copy;
use File::Basename;
use File::Temp qw/ tempfile tempdir :mktemp /;
#use File::state;
use Fcntl qw(:mode);

use strict;
use warnings;

use lib "misc";
use config_host;
use myutils;
use benchmarks;
#use rewrite;
use execute;
#use binprobe;

our @all_execs;
our @all_opts;
our $srcdir;
our %args;
our %opts;
our %small_args;

my $run_iter = 1;
my $small_inputs = 0;

sub usage
{
  print "./specrun.pl -bench 2000|2006 [exec1 exec2 ...]\n";
  exit(1);
}

my $bench;
GetOptions(
  "bench=s" => \$bench
);

my $specdir;
my @all_execs;

if ($bench eq "2000") {
  $specdir = "$build_dir/specs2000";
  @all_execs = @all_specs2000;
} elsif ($bench eq "2006") {
  $specdir = "$build_dir/specs2006";
  @all_execs = @all_specs2006;
} else {
  usage();
}



my $comp_out;

sub get_bench_from_exec
{
  my $exec = shift;
  if ($exec =~ /^tmpexec\.([^\.]+)\./) {
    return $1;
  } else {
    return $exec;
  }
}

$| = 1;     # turn on autoflush of stdout

my @execs
foreach my $e (@all_execs) {
  push(@execs, spec_exec_name($e));
}

#@execs = ("cc1", "perlbmk", "gap", "bzip2", "twolf", "gzip", "vpr", "mcf", "crafty", "parser", "eon");
#@execs = @all_execs;

if ($#ARGV >= 0) {
  @execs = ();
  my %new_opts;
  foreach my $argv (@ARGV) {
    my $opt_found = 0;
    foreach my $opt (@all_opts) {
      if ($argv =~ /^(.*)\.$opt$/) {
        my $exec = $1;
        @execs = (@execs, $exec) if !array_belongs($exec, \@execs);
        my @exec_opts;
        if (defined $new_opts{$exec}) {
          @exec_opts  = (@{$new_opts{$exec}}, $opt);
        } else {
          @exec_opts = ($opt);
        }
        $new_opts{$exec} = \@exec_opts;
        $opt_found = 1;
      }
    }
    @execs = (@execs, $argv) if !$opt_found;
  }
  foreach my $exec (@execs) {
    $opts{$exec} = $new_opts{$exec} if (defined $new_opts{$exec});
  }
}

$SIG{INT} = \&interrupt_exit;

#print "Testing write_new_peep_tab() tmp_peep_tab=$tmp_peep_tab\n";
#write_new_peep_tab($num_peep_intervals, \@start_peep_intervals, \@stop_peep_intervals);

for my $cur_exec (@execs) {
  for my $opt (get_opts($cur_exec)) {
    for (my $iter = 0; $iter < $run_iter; $iter++) {
      my $i386_execfile = get_execfile($cur_exec, $opt, "i386");
      my $cur_exec_bench = get_bench_from_exec($cur_exec);
      my @cur_args;
      @cur_args = @{$args{$cur_exec_bench}};
      for my $cur_arg (@cur_args) {
        my $command = "$i386_execfile $cur_arg";
	#print "$command\n";
        my $start = Time::HiRes::time;
        system("bash -c \"$command > out 2> err\"");
        my $stop = Time::HiRes::time;
	$stop = $stop - $start;
        print "$cur_exec :";
        print " $opt : ";
        print " iter$iter :";
	print " $stop\n";
      }
    }
  }
  print "\n";
}

