#!/usr/bin/perl -w
use strict;
use warnings;
use Switch;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval );
use File::Copy;
use File::Temp qw/ tempfile tempdir :mktemp /;
use POSIX;
use POSIX ":sys_wait_h";
use POSIX qw(setsid);
use POSIX qw(:errno_h :fcntl_h);
use Unix::Mknod qw(:all);
use Fcntl qw(:mode);

use threads ('yield',
             'stack_size' => 64*4096,
             'exit' => 'threads_only',
             'stringify');

sub array_belongs
{
  my $elem = shift;
  my $arr = shift;
  foreach my $a (@$arr)
  {
    return 1 if ($elem eq $a);
  }
  return 0;
}

sub xsystem
{
  my $command = shift;
  my $ret = system($command);
  if (WIFSIGNALED($ret)) {
    #print "\nTried executing $command\nReceived signal ";
    switch (WTERMSIG($ret)) {
      case SIGINT		{ print "SIGINT" }
      case SIGKILL		{ print "SIGKILL" }
      case SIGSEGV		{ print "SIGSEGV" }
      case SIGABRT		{ print "SIGABRT" }
    }
    #print ". exiting\n";
    return(-1);
  }
  if (WIFEXITED($ret)) {
    if (WEXITSTATUS($ret) != 0) {
      #printf("Translation exited with status %d. exiting\n", WEXITSTATUS($ret));
      return(-1);
    }
  }
  return 0;
}

sub axsystem
{
  my $command = shift;
  my $thr = threads->create('xsystem', $command);
  $thr->detach();
  return $thr;
}


sub kill_recursive
{
  my $sig = shift;
  my $pid = shift;

  my @children;
  open (PS_OUTPUT, "pgrep -P $pid|");
  while (my $line = <PS_OUTPUT>)
  {
    if ($line =~ /^(\S*)$/)
    {
      push(@children, $1);
    }
  }
  close (PS_OUTPUT);

  print "Killing process $pid with signal $sig\n";
  kill ($sig,$pid);

  foreach my $child (@children)
  {
    kill_recursive($sig, $child);
  }
}

sub timed_exec
{
  my $command = shift;
  my $secs = shift;
  pipe my $pparent , my $pchild or die;

  my $child = fork();
  defined $child or die "fork failed.\n";

  if ($child == 0) {
    close $pparent;
    my $start_time = Time::HiRes::time;
    print "running \"$command\"\n";
    system("bash -c \"$command\"");
    my $stop_time = Time::HiRes::time;
    #print "start_time=$start_time, stop_time=$stop_time\n";
    my $elapsed = int(($stop_time-$start_time)*1000);
    #print "elapsed time: $elapsed\n";
    print $pchild "elapsed time: $elapsed\n";
    close $pchild;
    exit (123);
    #return $elapsed;
  } else {
    close $pchild;
    for (my $i=0; $i<$secs;$i++) {
      sleep(1);
      my $pid = waitpid ($child, WNOHANG);
      #
      #  # waitpid can return non-zero even if the process stops (these are
      #  # called false alarms.
      #  # see http://www.unix.org.ua/orelly/perl/cookbook/ch16_20.htm
      #  # see http://www.unix.org.ua/orelly/perl/prog/ch03_190.htm
      if ($pid > 0 && WIFEXITED($?)) {
	if (WEXITSTATUS($?) == 123) {
	  my $time;
	  defined (my $line = <$pparent>) or die;
	  if ($line =~ /elapsed time: (.*)$/) {$time = $1;}
	  defined $time or die;
	  #print "parent: elapsed time = $time\n";
	  close ($pparent);

	  return $time;
	} else {
	  return -1;
	}
      }
    }

    print "Process failed to finish in $secs seconds\n";
    kill_recursive "KILL", $child;
    return -1;
  }
}



sub touch
{
  my $filename = shift;
  my $pathname = $filename;
  my @path = ();
  my $pattern = "([^\/]+)\/([^\/]*)";
  while ($pathname =~ /^(.*)\/$pattern$/) {
    $pathname = $1;
    my $parentdir = $2;
    @path = ($parentdir, @path);
    $pathname = "$pathname/$parentdir";
  }

  if ($pathname =~ /$pattern/) {
    my $parentdir = $1;
    @path = ($parentdir, @path);
  }
  if ($filename =~ /^\//) {
    @path = ("/", @path);
  }
  my $pathlen = scalar @path;
  #print "path($pathlen): @path\n";

  my $curwd = $ENV{'PWD'};
  my $curpath = "";
  foreach my $dir (@path) {
    if (!(-e $dir)) {
      mkdir $dir or die "mkdir $curpath$dir failed: $!\n";
    }

    (-d $dir) or die "$curpath$dir exists but not as directory\n";
    chdir $dir or die "chdir $curpath$dir failed: $!\n";
    $curpath = "$curpath$dir/"
  }

  chdir $curwd;
  open (my $fd, ">$filename") or die "failed to open $filename:$!\n";
  close ($filename);
}

sub diff
{
  my $file1 = shift;
  my $file2 = shift;
  my $partial = shift; #first file is allowed to be part-of second one but not vice-versa

  open (FILE1, "<$file1");
  open (FILE2, "<$file2");

  my ($line1, $line2);

  my $linenum = 0;
	while (defined($line1 = <FILE1>)) {
		if (!($line2 = <FILE2>)) {
			print "\tline1 $linenum: $line1";
			print "\tline2 $linenum: (not defined)\n";
			close (FILE1);
			close (FILE2);
			return 1;
		}

		my @words1 = split(/ /, $line1);
		my @words2 = split(/ /, $line2);

		if ($partial == 0 || $line1 =~ /^\n/) {
      #print "words1: @words1";
      #print "words2: @words2";
			if (!arrays_equal(\@words1, \@words2)) {
		    close (FILE1);
		    close (FILE2);
		    return 1;
      }
    }
    $linenum++;
  }

  if (!$partial &&  (defined($line2 = <FILE2>))) {
    close (FILE1);
    close (FILE2);
    print "\tline1 $linenum: (null)\n\tline2 $linenum: $line2";
    return 1;
  }

  close (FILE1);
  close (FILE2);
  return 0;
}

sub MAX
{
  my $a = shift;
  my $b = shift;
  if ($a<$b) { return $b; }
  else { return $a; }
}

sub MIN
{
  my $a = shift;
  my $b = shift;
  return $a if (!(defined $b));
  return $b if (!(defined $a));
  if ($a>$b) { return $b; }
  else { return $a; }
}

sub arrays_equal
{
  my ($first, $second) = @_;
  return 0 unless @$first == @$second;
  for (my $i = 0; $i < @$first; $i++) {
    if ($first->[$i] ne $second->[$i]) {
      #print "first: $first->[$i]\n";
      #print "second: $second->[$i]\n";
      #if ($first->[$i] =~ /\*/ && $second->[$i] =~ /\*/) {
      #  return 0;
      #}
      return 0;
    }
  }
  return 1;
}

1;
