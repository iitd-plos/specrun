#!/usr/bin/perl -w
use strict;
use warnings;
use Switch;
use config_host;

#our $srcdir = "/home/sbansal/superopt";
our $srcdir;
our $superopt_build = $srcdir."-build";
our $spec_dir = "$superopt_build/specs";
our $spec_ref = "$spec_dir/ref";
our $spec_all = "$spec_dir/all";
our $spec_test = "$spec_dir/test";

#our @default_opts = ("O2", "O0", "O3", "O3f");
#our @default_opts = ("O2", "O0");
our @default_opts = ("O2");

our @all_specs = ("253.perlbmk", "254.gap", "256.bzip2", "300.twolf", "164.gzip", "175.vpr", "181.mcf", "186.crafty", "197.parser", "252.eon", "176.gcc");
#, "255.vortex"

#@default_opts = ("O0");
#@all_specs = ("253.perlbmk");

sub spec_exec_name {
  my $exec = shift;
  $exec =~ /^\d*\.(.*)$/;
  my $exname = ($1 eq "gcc")?"cc1":$1;
  return $exname;
}

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

our $cpu2000 = "$superopt_build/installs/spec_cpu_2000";
our $cint2000 = "$cpu2000/benchspec/CINT2000";

our $cpu2006 = "$superopt_build/installs/cpu2006";
our $cint2006 = "$cpu2000/benchspec/CPU2006";

our @mcf_args = ("$spec_ref/inp.in");
our @bzip2_args = ("$spec_ref/input.source", "$spec_ref/input.graphic", "$spec_ref/input.program");
our @gzip_args = ("$spec_ref/input.source 60", "$spec_ref/input.graphic 60", "$spec_ref/input.program 60", "$spec_ref/input.random 60", "$spec_ref/input.log 60");
our @parser_args =("2.1.dict.mod -batch < $spec_ref/ref.in > /tmp/out");
our @vpr_args = ("$spec_ref/net.in $spec_ref/arch.in /tmp/place.out /tmp/dum.out -nodisp -place_only -init_t 5 -exit_t 0.005 -alpha_t 0.9412 -inner_num 2", "$spec_ref/net.in $spec_ref/arch.in $spec_ref/place.in /tmp/route.out -nodisp -route_only -route_chan_width 15 -pres_fac_mult 2 -acc_fac 1 -first_iter_pres_fac 4 -initial_pres_fac 8");
our @twolf_args = ("$superopt_build/ref");
our @vortex_args = ("$spec_ref/lendian1.raw", "$spec_ref/lendian2.raw", "$spec_ref/lendian3.raw");
our @cc1_args = ("$spec_ref/166.i -o $spec_ref/166.s", "$spec_ref/200.i -o $spec_ref/200.s", "$spec_ref/expr.i -o $spec_ref/expr.s", "$spec_ref/integrate.i -o $spec_ref/integrate.s", "$spec_ref/scilab.i -o $spec_ref/scilab.s");
our @crafty_args = (" < $spec_ref/crafty.in");
our @eon_args = ("$spec_ref/chair.control.cook $spec_ref/chair.camera $spec_ref/chair.surfaces $spec_ref/chair.cook.ppm ppm $spec_ref/pixels_out.cook", "$spec_ref/chair.control.rushmeier $spec_ref/chair.camera $spec_ref/chair.surfaces $spec_ref/chair.rushmeier.ppm ppm $spec_ref/pixels_out.rushmeier", "$spec_ref/chair.control.kajiya $spec_ref/chair.camera $spec_ref/chair.surfaces $spec_ref/chair.kajiya.ppm ppm $spec_ref/pixels_out.kajiya");
our @gap_args = (" -l $spec_all -q -m 192M < $spec_ref/ref.in");
our @perlbmk_args = ("-I$spec_all/lib $spec_all/diffmail.pl 2 550 15 24 23 100", "-I$spec_all -I$spec_all/lib $spec_ref/makerand.pl", "-I$spec_all/lib $spec_all/perfect.pl b 3 m 4", "-I$spec_all/lib $spec_ref/splitmail.pl 850 5 19 18 1500", "-I$spec_all/lib $spec_ref/splitmail.pl 704 12 26 16 836", "-I$spec_all/lib $spec_ref/splitmail.pl 535 13 25 24 1091", "-I$spec_all/lib $spec_ref/splitmail.pl 957 12 23 26 1014");

our @twolf_small_args = ("$spec_test/test");
our @perlbmk_small_args = ("$spec_test/arith.t");
our @eon_small_args = ("$spec_test/chair.control.cook $spec_test/chair.camera $spec_test/chair.surfaces $spec_test/chair.cook.ppm ppm $spec_test/pixels_out.cook");
our @gap_small_args = (" -l $spec_ref -q -m 192M < $spec_test/gap.test.in");
our @vpr_small_args = ("$spec_test/net.in $spec_test/arch.in /tmp/place.out /tmp/dum.out -nodisp -place_only -init_t 5 -exit_t 0.005 -alpha_t 0.9412 -inner_num 2");
our @mcf_small_args = ("$spec_test/inp.in");
our @vortex_small_args = ("$spec_test/lendian1.raw", "$spec_test/lendian2.raw", "$spec_test/lendian3.raw");
our @gzip_small_args = ("", "$spec_test/input.compressed");
our @bzip2_small_args = ("", "$spec_test/input.random");


our %args, our %small_args;
$args{"fibo"} = \@fibo_args;
$args{"hello_world"} = \@hello_world_args;
$args{"one_bbl"} = \@one_bbl_args;
$args{"combox"} = \@combox_args;
$args{"mcf"} = \@mcf_args;
$args{"bzip2"} = \@bzip2_args;
$args{"gzip"} = \@gzip_args;
$args{"parser"} = \@parser_args;
$args{"twolf"} = \@twolf_args;
$args{"vpr"} = \@vpr_args;
$args{"crafty"} = \@crafty_args;
$args{"cc1"} = \@cc1_args;
$args{"eon"} = \@eon_args;
$args{"perlbmk"} = \@perlbmk_args;
$args{"gap"} = \@gap_args;
$args{"vortex"} = \@vortex_args;

$small_args{"twolf"} = \@twolf_small_args;
$small_args{"perlbmk"} = \@perlbmk_small_args;
$small_args{"eon"} = \@eon_small_args;
$small_args{"gap"} = \@gap_small_args;
$small_args{"vpr"} = \@vpr_small_args;
$small_args{"mcf"} = \@mcf_small_args;
$small_args{"gzip"} = \@gzip_small_args;
$small_args{"bzip2"} = \@bzip2_small_args;
$small_args{"vortex"} = \@vortex_small_args;

sub specs_args_patsubst
{
  my $args = shift;
  my $pat = shift;
  my $rep = shift;
  for my $spec (@all_specs) {
    my $exname = spec_exec_name($spec);
    my %hargs = %$args;
    my $elem = $hargs{$exname};
    if (defined $elem) {
      my @eargs = @$elem;
      my @new_eargs = ();
      foreach my $earg (@eargs) {
        $earg =~ s/$pat/$cint2000\/$spec\/data\/$rep\/input/g;
        push(@new_eargs, $earg);
      }
      $$args{$exname} = \@new_eargs;
    }
  }
}

specs_args_patsubst(\%args, $spec_ref, "ref");
specs_args_patsubst(\%args, $spec_all, "all");
specs_args_patsubst(\%small_args, $spec_test, "test");
specs_args_patsubst(\%small_args, $spec_all, "all");

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

our @all_opts = ();
for my $cur_exec (keys %args) {
  my @opts = get_opts($cur_exec);
  for my $opt (@opts) {
    if (!array_belongs($opt, \@all_opts)) {
      @all_opts = (@all_opts, $opt);
    }
  }
}

sub is_spec_benchmark
{
  my $bench = shift;
  for my $spec (@all_specs) {
    return 1 if ($bench eq spec_exec_name($spec));
  }
  return 0;
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
  my $bench = shift;
  my $option = shift;
  my $arch = shift;

  my @my_opts = get_opts($bench);
  foreach my $opt (@my_opts) {
    if ($opt eq $option) {
      if (is_spec_benchmark($bench)) {
        return "$superopt_build/specs/$arch-$option/$bench";
      } elsif ($bench =~ /^tmpexec/) {
        return "$superopt_build/tmpexecs/$bench.$option.$arch";
      } else {
        return "$superopt_build/benches/$bench.$option.$arch";
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

sub make_endianness_adjustments
{
  my $bench = shift;
  my $arch = shift;

  if ($bench =~ /parser/) {
    unlink("2.1.dict.mod");
    system("rm -rf words");
    symlink("$cint2000/197.parser/data/all/input/2.1.dict.mod", "2.1.dict.mod")
      or die "symlink $cint2000/197.parser/data/all/2.1.dict.mod failed: $!\n";
    symlink("$cint2000/197.parser/data/all/input/words", "words")
      or die "symlink $cint2000/197.parser/data/all/input/words failed: $!\n";
  }
  if ($bench =~ /eon/) {
    copy("$cint2000/252.eon/data/ref/input/eon.dat", "eon.dat")
      or die "Copy eon.dat failed: $!\n";
    copy("$cint2000/252.eon/data/ref/input/spectra.dat", "spectra.dat")
      or die "Copy spectra.dat failed: $!\n";
    copy("$cint2000/252.eon/data/ref/input/materials", "materials")
      or die "Copy materials failed: $!\n";
  }
  if ($bench =~ /vortex/) {
    copy("$cint2000/255.vortex/data/ref/input/persons.1k", "persons.1k")
      or die "Copy persons.1k failed: $!\n";
    copy("$cint2000/255.vortex/data/ref/input/lendian.rnv", "lendian.rnv")
      or die "Copy lendian.rnv failed: $!\n";
    copy("$cint2000/255.vortex/data/ref/input/lendian.wnv", "lendian.wnv")
      or die "Copy lendian.wnv failed: $!\n";
  }
#  switch ($bench) {
#    case /perlbmk/ {
#      if ($arch eq "ppc") {
#        unlink("lenums");
#        symlink("$spec_ref/benums", "lenums")
#          or die "symlink $spec_ref/benums lenums failed: $!\n";
#      } elsif ($arch eq "i386") {
#        unlink("lenums");
#        symlink("$spec_ref/lenums", "lenums")
#          or die "symlink $spec_ref/lenums lenums failed: $!\n";
#      } else {die;}
#    }
#    case /vortex/ {
#      if ($arch eq "ppc") {
#        unlink("$spec_ref/xendian1.raw");
#        unlink("$spec_ref/xendian2.raw");
#        unlink("$spec_ref/xendian3.raw");
#        symlink ("$spec_ref/bendian1.raw", "$spec_ref/xendian1.raw")
#          or die "symlink $spec_ref/bendian1.raw $spec_ref/xendian1.raw failed: $!\n";
#        symlink ("$spec_ref/bendian2.raw", "$spec_ref/xendian2.raw")
#          or die "symlink $spec_ref/bendian2.raw $spec_ref/xendian2.raw failed: $!\n";
#        symlink ("$spec_ref/bendian3.raw", "$spec_ref/xendian3.raw")
#          or die "symlink $spec_ref/bendian3.raw $spec_ref/xendian3.raw failed: $!\n";
#
#        unlink("$spec_test/xendian.raw");
#        symlink ("$spec_test/bendian.raw", "$spec_test/xendian.raw")
#          or die "symlink $spec_test/bendian.raw $spec_test/xendian.raw failed: $!\n";
#      } elsif ($arch eq "i386") {
#        unlink("$spec_ref/xendian1.raw");
#        unlink("$spec_ref/xendian2.raw");
#        unlink("$spec_ref/xendian3.raw");
#        symlink ("$spec_ref/lendian1.raw", "$spec_ref/xendian1.raw")
#          or die "symlink $spec_ref/lendian1.raw $spec_ref/xendian1.raw failed: $!\n";
#        symlink ("$spec_ref/lendian2.raw", "$spec_ref/xendian2.raw")
#          or die "symlink $spec_ref/lendian2.raw $spec_ref/xendian2.raw failed: $!\n";
#        symlink ("$spec_ref/lendian3.raw", "$spec_ref/xendian3.raw")
#          or die "symlink $spec_ref/lendian3.raw $spec_ref/xendian3.raw failed: $!\n";
#
#        unlink("$spec_test/xendian.raw");
#        symlink ("$spec_test/lendian.raw", "$spec_test/xendian.raw")
#          or die "symlink $spec_test/lendian.raw $spec_test/xendian.raw failed: $!\n";
#      }
#    } else {}
#  }
}
our @spec_execs;
foreach my $exec (@all_specs) {
  push(@spec_execs, spec_exec_name($exec));
}
our @all_execs = ("hello_world", "one_bbl", "fibo", "combox", @spec_execs);

1;
