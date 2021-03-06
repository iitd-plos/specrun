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

#our @all_execs;
our @all_opts;
our $srcdir;
our %args;
our %opts;
our %small_args;
our %prep_commands;
our $build_dir;
our @all_specs2000;
our @all_specs2006;
our @default_opts;


my $run_iter = 1;
my $small_inputs = 0;

sub usage
{
  print "./specrun.pl -bench 2000|2006 -ext <all|i386|x64|ppc|O0|O2|O2ofp|O3|O3U|pg|".
         "soft-float|hard-float|<ext>> [exec1 exec2 ...]\n";
  exit(1);
}

my $bench;
my $extension;

GetOptions(
  "bench=s" => \$bench,
  "extension=s" => \$extension,
);
 
my $specname;
my $specdir;
my @all_execs;

if ($bench eq "2000") {
  $specname = "spec2000";
  @all_execs = @all_specs2000;
} elsif ($bench eq "2006") {
  $specname = "spec2006";
  @all_execs = @all_specs2006;
} else {
  usage();
}
$specdir = "$build_dir/$specname";

$extension = "all" if (!$extension);

@default_opts = get_cfgs_from_extension($extension);

$| = 1;     # turn on autoflush of stdout

my @execs;
foreach my $e (@all_execs) {
  push(@execs, spec_exec_name($specname, $e));
}

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

sub get_bench_from_exec
{
  my $exec = shift;
  if ($exec =~ /^tmpexec\.([^\.]+)\./) {
    return $1;
  } else {
    return $exec;
  }
}

$SIG{INT} = \&interrupt_exit;

for (my $iter = 0; $iter < $run_iter; $iter++) {
  for my $cur_exec (@execs) {
    for my $opt (get_opts($cur_exec)) {
      my $execfile = get_execfile($specname, $cur_exec, $opt);
      #print "execfile= $execfile\n";
      my $cur_exec_bench = get_bench_from_exec($cur_exec);
      #print "cur_exec_bench= $cur_exec_bench\n";
      $cur_exec_bench = "$specname.$cur_exec_bench";
      make_endianness_adjustments($cur_exec_bench, "i386");
      defined $args{"$cur_exec_bench"}
        or die "args undefined for $cur_exec_bench.\n";
      my @cur_args;
      @cur_args = @{$args{$cur_exec_bench}};
      my $argnum = 0;
      my $prepcmd = $prep_commands{$cur_exec_bench};
      $prepcmd = "/bin/true" if (not defined $prepcmd);
      for my $cur_arg (@cur_args) {
        #print "cur_arg = $cur_arg\n";
        my $command = "$execfile $cur_arg > out.$cur_exec_bench.arg$argnum 2> err.$cur_exec_bench.arg$argnum";
	#print "prepcmd: $prepcmd\n";
	#print "command: $command\n";
        my $start = Time::HiRes::time;
        system("bash -c \"mkdir -p $build_dir/run_tmpdir && cd $build_dir/run_tmpdir && $prepcmd && $command && cd -\"");
        my $stop = Time::HiRes::time;
	$stop = $stop - $start;
        print "$cur_exec :";
        print " arg$argnum :";
        print " $opt : ";
        print " iter$iter :";
	print " $stop\n";
        $argnum++;
      }
    }
  }
  print "\n";
}
