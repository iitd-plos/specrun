#!/usr/bin/perl -w
use strict;
use warnings;
use Switch;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval );
use lib "misc";
use config_host;
use myutils;
use benchmarks;

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


sub timed_exec_and_compare
{
  my $command = shift;
  my $outfile = shift;
  my $errfile = shift;
  my $ref_outfile = shift;
  my $failed_ref_outfile = shift;
  my $secs = shift;
  my $timeout_action = shift;
  my $output_files = shift;
  my $success_exitcode = 123;

  defined $outfile or die;
  defined $errfile or die;

  pipe my $pparent , my $pchild or die;

  my $child = fork();
  if (not defined $child) {
    print "fork failed.\n"; exit(1);
  }

  if ($child == 0) {
    close $pparent;
    my $start_time = Time::HiRes::time;
    system("bash -c \"$command > $outfile 2> $errfile\"");
    my $status = $?;
    if (WIFSIGNALED($status)) {
      my $signal = WTERMSIG($status);
      print "signaled $signal\n";
      if ($signal == SIGSEGV) {
        exit(-1);
      }
    } elsif (WIFEXITED($status)) {
      my $code = WEXITSTATUS($status);
      if ($code != 0) {
        print "exited with status $code\n";
        exit(-1);
      }
    }

    my $stop_time = Time::HiRes::time;
    #print "start_time=$start_time, stop_time=$stop_time\n";
    my $elapsed = int(($stop_time-$start_time)*1000);
    #print "elapsed time: $elapsed\n";
    print $pchild "elapsed time: $elapsed\n";
    close $pchild;
    exit($success_exitcode);
    #return $elapsed;
  } else {
    close $pchild;
    for (my $i = 0; $i < $secs; $i++) {
      sleep(1);
      my $pid = waitpid($child, WNOHANG);
      my $status = $?;

      #print "waitpid() returned. status = $status.\n";
      # waitpid can return non-zero even if the process stops (these are
      # called false alarms.
      # see http://www.unix.org.ua/orelly/perl/cookbook/ch16_20.htm
      # see http://www.unix.org.ua/orelly/perl/prog/ch03_190.htm
      if ($pid > 0 && WIFEXITED($status)) {
        if (WEXITSTATUS($status) == $success_exitcode) {
          my $time;
          defined (my $line = <$pparent>) or die;
          if ($line =~ /elapsed time: (.*)$/) {$time = $1;}
          defined $time or die;
          #print "parent: elapsed time = $time\n";
          close ($pparent);

          #if (diff_files($outfile, $ref_outfile, $output_files, 0)) {
          #  return -1;
          #}
          return $time;
        } else {
          return -1;
        }
      }
      #if ($timeout_action == 1) {
      #  if (diff_files($outfile, $ref_outfile, $output_files, 1)) {
      #    print "\tStdout differs after $i seconds\n";
      #    kill_recursive "KILL", $child;
      #    return -1;
      #  } elsif (   (-e $failed_ref_outfile)
      #           && diff_files ($outfile, $failed_ref_outfile, $output_files, 1)) {
      #    print "\tStdout identical to correct output but differs from failed output after $i seconds. Returning SUCCESS\n";
      #    kill_recursive "KILL", $child;
      #    return ($i*1000);
      #  }
      #}
    }

    if ($timeout_action == 0) {
      print "Process failed to finish in $secs seconds\n";
      kill_recursive "KILL", $child;
      return -1;
    } elsif ($timeout_action == 1) {
      print "Process continuing even after $secs seconds. killing it and returning SUCCESS\n";
      kill_recursive "KILL", $child;
      return ($secs * 1000);
    }
  }
}

sub diff_files
{
  my $file1 = shift;
  my $file2 = shift;
  my $output_files = shift;
  my $partial = shift; #first file is allowed to be part of second but not vice-versa

  if ($file1 ne $file2) {
    #print "diffing (partial $partial): $file1 <-> $file2\n";
    if (diff($file1, $file2, $partial)) {
      return 1;
    }

    my @output_files_arr = @$output_files;
    for (my $i = 0; $i < $#output_files_arr; $i+=2) {
      my $output_file = $output_files_arr[$i];
      my $ref_output_file = $output_files_arr[$i+1];
      #print "diffing (partial $partial): $output_file <-> $ref_output_file\n";
      if (diff($output_file, $ref_output_file, $partial)) {
				return 1;
			}
		}
  }
  return 0;
}

1;
