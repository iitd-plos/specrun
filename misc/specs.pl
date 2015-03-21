#!/usr/bin/perl
use POSIX ":sys_wait_h";
use Switch;
use Getopt::Std;

our $flags = "-ff -prune 1 -no-calling-conventions -no-aggressive";

sub kill_recursive
{
  my $sig = shift;
  my $pid = shift;

  my @children;
  open (PS_OUTPUT, "pgrep -P $pid|");
  while (my $line = <PS_OUTPUT>) {
    if ($line =~ /^(\S*)$/) {
      push(@children, $1);
    }
  }
  close (PS_OUTPUT);

  print "Killing process $pid with signal $sig\n";
  kill ($sig,$pid);

  foreach my $child (@children) {
    kill_recursive($sig, $child);
  }
}

sub killall_children {
  system ("killall_children.sh specs.pl");
  print "Exiting..\n";
  exit (1);
}

sub read_logfile {
  my $logfile = shift;
  my $ratio_ref = shift;
  my $runtime_ref = shift;

  open (LOGFILE, "<$logfile");

  while ($line = <LOGFILE>) {
    if ($line =~ /Success [^ ]* ratio=([0-9]*.[0-9]*), runtime=(.*)/) {
      $$ratio_ref = $1;
      $$runtime_ref = $2;
      close (LOGFILE);
      return 1;
    }
  }
  close (LOGFILE);
  return 0;
}

sub get_benchmark
{
  my $exec = shift;
  switch ($exec) {
    case "gzip"		{ return ($exec, 164); }
    case "vpr"		{ return ($exec, 175); }
    case "cc1"		{ return ("gcc", 176); }
    case "mcf"		{ return ($exec, 181); }
    case "crafty"	{ return ($exec, 186); }
    case "parser"	{ return ($exec, 197); }
    case "eon"		{ return ($exec, 252); }
    case "perlbmk"	{ return ($exec, 253); }
    case "gap"		{ return ($exec, 254); }
    case "vortex"	{ return ($exec, 255); }
    case "bzip2"	{ return ($exec, 256); }
    case "twolf"	{ return ($exec, 300); }
  }
  print "unknown benchmark exec $exec. exiting.\n";
  exit(1);
}

#my @execs=("mcf", "bzip2", "gzip", "parser", "twolf", "vortex", "vpr","crafty",
#  "cc1");
my @execs=("mcf", "bzip2", "gzip", "parser", "vpr");

our %options=();
getopts("rqd:", \%options);

if ($#ARGV == 0) {
  @execs = ($ARGV[0]);
}

our $dir;
if (defined $options{d}) {
  $dir = $options{d};
  if ($dir ne "all" && $dir ne "ppc-base" && $dir ne "ppc-O2" && $dir ne "base"
    && $dir ne "O2") {
    undef $dir
  }
}

if (!(defined $dir)) {
  print("Please specify directory name using '-d' option (eg. ppc-base,".
    " ppc-O2, base, O2)\n");
  exit (1);
}

my @dirs;
if ($dir eq "all") {
  @dirs = ("ppc-base", "ppc-O2", "base", "O2");
} else {
  @dirs = ($dir);
}

$SIG{INT} = \&killall_children;

foreach my $dir (@dirs) {
  my $results_file = "spec.files/results.$dir";
  open (my $results_fp, ">$results_file");

  foreach my $exec (@execs) {
    my $dir_suffix = "";
    if ($dir eq "ppc-base" || $dir eq "ppc-O2") {
      $dir_suffix = ".trans";
      if (!(defined $options{r})) {
        if (defined $options{q}) {
          $flags .= " -q";
        }
        print "Translating $exec using flags $flags\n";
        system ("./rewrite $flags -o $dir.trans/$exec -l $dir.trans/$exec.log ".
          "$dir/$exec >& /dev/null");
      }
    }

    my ($benchname, $benchnum) = get_benchmark($exec);

    system ("cp $dir$dir_suffix/$exec $srcdir/../superopt-build/".
      "spec_cpu2000/benchspec/CINT2000/$benchnum.$benchname/exe/".
      "$exec\_base.none");

    print "Testing $dir/$exec\n";
    my $child = fork();

    if (not defined $child) {
      print "fork() failed. resources not available.\n";
      exit (1);
    }

    if ($child == 0) {
      my $status = system ("bash -c \"ulimit -c unlimited; ".
        "cd $srcdir/../superopt-build/spec_cpu_2000; ".
        "source shrc; rm -f result/log.*; ".
        "bin/runspec -n 1 $exec 2>&1 > /tmp/runspec.log\"");

      if ($status == -1) {
        print "failed to execute $exec\n";
        exit (1);
      } elsif ($status & 127) {
        printf("Child died with signal %e, %s coredump\n", ($status & 127),
          ($status & 128) ? 'with':'without');
      } else {
        printf("Exited with value %d\n", $status >> 8);

        my $ratio, $runtime;
        if (!read_logfile("$srcdir/../superopt-build/".
            "spec_cpu_2000/result/log.001", \$ratio, \$runtime)) {
          print "Error reading logfile.\n";
        } else {
          print "$exec: ratio = $ratio, runtime = $runtime\n";
          print $results_fp "$exec\t$runtime\n";
        }
        exit (0);
      }
    } else {
      my $child_finished = 0;
      my $MAX_MIN = 90;
      #The process should finish within $MAX_MIN minutes
      for (my $i = 0; $i < $MAX_MIN*60 && !$child_finished; $i++) {
        sleep(1);
        my $pid = waitpid ($child, WNOHANG);

        # waitpid can return non-zero even if the process stops (these are
        # called false alarms.
        # see http://www.unix.org.ua/orelly/perl/cookbook/ch16_20.htm
        # see http://www.unix.org.ua/orelly/perl/prog/ch03_190.htm
        if ($pid > 0 && WIFEXITED($?)) {
          print "Child finished in approximately $i seconds\n";
          $child_finished = 1;
        }
      }

      if (!$child_finished) {
        print "Process failed to finish in $MAX_MIN minutes\n";
        kill_recursive "KILL", $child;
      }
    }
  }

  close ($results_fp);
}

my %runtimes;
foreach my $exec (@execs) {
  my %runtime_fields;
  foreach my $dir ("ppc-base", "ppc-O2", "base", "O2") {
    my $results_file = "spec.files/results.$dir";
    open (my $results_fp, "<$results_file");
    while (my $line = <$results_fp>) {
      @fields = split(/\t/, $line);
      if ($fields[0] eq $exec) {
        $runtime_fields{$dir} = $fields[1];
      }
    }
    close ($results_fp);
    #unlink ($results_file); #XXX
  }
  $runtimes{$exec} = \%runtime_fields;
}

open (RESULTS, ">>SPEC.RESULTS");
my $now = localtime time;
print RESULTS "Results of run at time $now\n";
foreach my $exec (@exec) {
  my $rfields = $runtimes{$exec};
  my $line = "$exec";
  if ((defined $$rfields{"ppc-base"}) && (defined $$rfields{"base"})) {
    my $ppc_time = $$rfields{"ppc-base"};
    my $host_time = $$rfields{"base"};
    $line = sprintf("$line\t\t%.2f%% (ppc %.2f, host %.2f)",
      ($host_time*100)/$ppc_time, $ppc_time, $host_time);
  }
  if ((defined $$rfields{"ppc-O2"}) && (defined $$rfields{"O2"})) {
    my $ppc_time = $$rfields{"ppc-O2"};
    my $host_time = $$rfields{"O2"};
    $line = sprintf("$line\t\t%.2f%% (ppc %.2f, host %.2f)",
      ($host_time*100)/$ppc_time, $ppc_time, $host_time);
  }
  print RESULTS "$line\n";
}
close (RESULTS);
