#!/usr/bin/perl -w
use strict;
use warnings;
use Switch;
use config_host;
use spec2000_runargs;
use spec2006_runargs;

#our $srcdir = "/home/sbansal/superopt";
our $srcdir;
our %args;
our %small_args;
our $spec2000_dir;
our $build_dir;

our @default_opts = ();
my @soft_float = ("i386-O2-soft-float", "i386-O0-soft-float", "ppc-O0-soft-float",
  "ppc-O2-soft-float");
my @hard_float = ("i386-O2-hard-float", "i386-O0-hard-float", "ppc-O0-hard-float",
  "ppc-O2-hard-float");

our @all_specs2000;
our @all_specs2006;


our @fibo_args = ("");
our @hello_world_args = ("");
our @one_bbl_args = ("");
#our @combox_args = ("bubsort 10", "mergesort 10", "quicksort 10", "hanoi1 5",
#  "hanoi2 5", "hanoi3 5", "link_list_search 10", "binary_search 10",
#  "openhash_search 10", "closedhash_search 10");
our @combox_args = ("bubsort 10000", "mergesort 10000000",
  "quicksort 10000000", "hanoi1 26", "hanoi2 26", "hanoi3 26",
  "fibo_iter 100000000", "fibo_rec 40", "emptyloop 100000000", 
  "link_list_search 200000","binary_search 10000000","openhash_search 10000000",
  "closedhash_search 400000", "sum8 100000000", "image_diff 8000000",
  "min 8000000", "comparison 8000000", "xor 8000000", "sprite_copy 8000000");

our %opts;
my @as_opt = ("AS");
my @o0_o2_o2p_opt = ("O0", "O2", "O2p");
my @o0_opt = ("O0");
my @o2_opt = ("O2");
my @o0_o2_opt = ("O2", "O0");
$opts{"hello_world"} = \@as_opt;
$opts{"fibo"} = \@as_opt;
$opts{"one_bbl"} = \@as_opt;
#$opts{"combox"} = \@o0_o2_o2p_opt;
#$opts{"gap"} = \@o2_opt;
#$opts{"vortex"} = \@o0_opt;

$args{"fibo"} = \@fibo_args;
$args{"hello_world"} = \@hello_world_args;
$args{"one_bbl"} = \@one_bbl_args;
$args{"combox"} = \@combox_args;


our @all_opts = ();
for my $cur_exec (keys %args) {
  my @opts = get_opts($cur_exec);
  for my $opt (@opts) {
    if (!array_belongs($opt, \@all_opts)) {
      @all_opts = (@all_opts, $opt);
    }
  }
}

sub get_opts
{
  my $bench = shift;
  my @my_opts = @default_opts;
  if (defined $opts{$bench}) {
    @my_opts = @{$opts{$bench}};
  }
  return @my_opts;
}

sub get_execfile
{
  my $specname = shift;
  my $bench = shift;
  my $option = shift;
  #my $arch = shift;

  my @my_opts = get_opts($bench);
  foreach my $opt (@my_opts) {
    if ($opt eq $option) {
      if (is_spec2000_benchmark($bench) || is_spec2006_benchmark($bench)) {
        return "$build_dir/$specname/$option/$bench";
      } elsif ($bench =~ /^tmpexec/) {
        return "$build_dir/tmpexecs/$option/$bench";
      } else {
        return "$build_dir/benches/$option/$bench";
      }
    }
  }
  return 0;
}

sub get_compare_files
{
  my $cur_exec = shift;
  my $argnum = shift;

  my @files = ();

  if ($cur_exec eq "vortex") {
    my $input_num = $argnum+1;
    @files = (@files, "vortex$input_num.out");
    @files = (@files, "vortex$input_num.out.ref");
    @files = (@files, "vortex.msg");
    @files = (@files, "vortex.msg.ref.$input_num");
  }
  return \@files;
}

our @nonspec_execs = ("hello_world", "one_bbl", "fibo", "combox");

sub get_cfgs_from_extension {
  my $extension = shift;
  my @cfgs;
  switch ($extension) {
    case "all" {@cfgs = ("gcc-i386-O0", "gcc-i386-O2", "gcc-i386-O3", "gcc-i386-O3U", "gcc-x64-O0", "gcc-x64-O2", "gcc-x64-O3", "gcc-x64-O3U", "gcc-x64-O3ofp",
        #"crosstool-i386-O0", "crosstool-i386-O2", "crosstool-i386-O3", "crosstool-i386-O3U",
        #"clang-i386-O0", "clang-i386-O2", "clang-i386-O3", "clang-i386-O3U",
        "clang-x64-O0", "clang-x64-O2", "clang-x64-O3", "clang-x64-O3U", "clang-x64-O3ofp",
        #"icc-i386-O0", "icc-i386-O2", "icc-i386-O3", "icc-i386-O3U", "icc-x64-O0", "icc-x64-O2", "icc-x64-O3", "icc-x64-O3U",
        #"crosstool-ppc-O0", "crosstool-ppc-O2", "crosstool-ppc-O3", "crosstool-ppc-O3U")
    );}
    case "i386" {@cfgs = ("gcc-i386-O0", "gcc-i386-O2", "gcc-i386-O2U", "gcc-i386-O2u", "gcc-i386-O2ofp", "gcc-i386-O3", "gcc-i386-O3U", "gcc-i386-O3u", "gcc-i386-O3ofp",
        #"clang-i386-O0", "clang-i386-O2", "clang-i386-O2U", "clang-i386-O3", "clang-i386-O3U",
        #"icc-i386-O0", "icc-i386-O2", "icc-i386-O3", "icc-i386-O3U", "icc-x64-O0", "icc-x64-O2", "icc-x64-O3", "icc-x64-O3U")
    );}
    case "x64" {@cfgs = ("gcc-x64-O0", "gcc-x64-O2", "gcc-x64-O2U", "gcc-x64-O2u", "gcc-x64-O2ofp", "gcc-x64-O3", "gcc-x64-O3U", "gcc-x64-O3u", "gcc-x64-O3ofp",
        "clang-x64-O0", "clang-x64-O2", "clang-x64-O2U", "clang-x64-O2u", "clang-x64-O2ofp", "clang-x64-O3", "clang-x64-O3U", "clang-x64-O3u", "clang-x64-O3ofp",
        #,"icc-x64-O0", "icc-x64-O2", "icc-x64-O3", "icc-x64-O3U", "icc-x64-O0", "icc-x64-O2", "icc-x64-O3", "icc-x64-O3U")
    );}
    case "x64-i386" {@cfgs = ("gcc-x64-O0", "gcc-i386-O0", "gcc-x64-O2", "gcc-i386-O2", "gcc-x64-O2U", "gcc-i386-O2U", "gcc-x64-O2u", "gcc-i386-O2u", "gcc-x64-O2ofp", "gcc-i386-O2ofp", "gcc-x64-O3", "gcc-i386-O3", "gcc-x64-O3U", "gcc-i386-O3U", "gcc-x64-O3u", "gcc-i386-O3u", "gcc-x64-O3ofp", "gcc-i386-O3ofp",
        "clang-x64-O0", "clang-x64-O2", "clang-x64-O2U", "clang-x64-O2u", "clang-x64-O2ofp", "clang-x64-O3", "clang-x64-O3U", "clang-x64-O3u", "clang-x64-O3ofp",
        #,"icc-x64-O0", "icc-x64-O2", "icc-x64-O3", "icc-x64-O3U", "icc-x64-O0", "icc-x64-O2", "icc-x64-O3", "icc-x64-O3U")
    );}
    case "x64-i386-O3" {@cfgs = ("gcc-x64-O3", "gcc-i386-O3",
         "clang-x64-O3"
        #,"icc-x64-O0", "icc-x64-O2", "icc-x64-O3", "icc-x64-O3U", "icc-x64-O0", "icc-x64-O2", "icc-x64-O3", "icc-x64-O3U")
    );}
    case "ppc" {@cfgs = ("crosstool-ppc-O0", "crosstool-ppc-O2", "crosstool-ppc-O3", "crosstool-ppc-O3U");}
    case "O0" {@cfgs = ("crosstool-i386-O0", "crosstool-ppc-O0");}
    case "O2" {@cfgs = ("crosstool-i386-O2", "crosstool-ppc-O2");}
    case "O2ofp" {@cfgs = ("crosstool-i386-O2ofp");}
    case "O3" {@cfgs = ("crosstool-i386-O3", "crosstool-ppc-O3");}
    case "O3U" {@cfgs = ("crosstool-i386-O3U", "crosstool-ppc-O3U");}
    case "pg" {@cfgs = ("crosstool-i386-O0-pg", "crosstool-i386-O2-pg", "crosstool-ppc-O0-pg", "crosstool-ppc-O2-pg");}
    case "soft-float" {@cfgs = @soft_float;}
    case "hard-float" {@cfgs = @hard_float;}
    else { print "extension $extension\n"; @cfgs = ("$extension"); }
  }
  return @cfgs;
}

1;
