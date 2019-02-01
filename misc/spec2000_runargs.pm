#!/usr/bin/perl -w
use strict;
use warnings;
use Switch;
use config_host;
use spec_common;

our $build_dir;
our (%args, %small_args, %prep_commands);

our @all_specs2000 = ("176.gcc", "253.perlbmk", "254.gap", "256.bzip2", "300.twolf", "164.gzip", "175.vpr", "181.mcf", "186.crafty", "197.parser", "252.eon", "255.vortex");
#our @all_specs2000 = ("256.bzip2");

our $cpu2000 = "$build_dir/installs/spec_cpu_2000";
our $cint2000 = "$cpu2000/benchspec/CINT2000";

our $spec2000_dir = "$build_dir/spec2000";
our $spec2000_ref = "$spec2000_dir/ref";
our $spec2000_all = "$spec2000_dir/all";
our $spec2000_test = "$spec2000_dir/test";


our @mcf_args = ("$spec2000_ref/inp.in");
our @bzip2_args = ("$spec2000_ref/input.source", "$spec2000_ref/input.graphic", "$spec2000_ref/input.program");
our @gzip_args = ("$spec2000_ref/input.source 60", "$spec2000_ref/input.graphic 60", "$spec2000_ref/input.program 60", "$spec2000_ref/input.random 60", "$spec2000_ref/input.log 60");
our @parser_args =("2.1.dict.mod -batch < $spec2000_ref/ref.in > /tmp/out");
our @vpr_args = ("$spec2000_ref/net.in $spec2000_ref/arch.in /tmp/place.out /tmp/dum.out -nodisp -place_only -init_t 5 -exit_t 0.005 -alpha_t 0.9412 -inner_num 2", "$spec2000_ref/net.in $spec2000_ref/arch.in $spec2000_ref/place.in /tmp/route.out -nodisp -route_only -route_chan_width 15 -pres_fac_mult 2 -acc_fac 1 -first_iter_pres_fac 4 -initial_pres_fac 8");
our @twolf_args = ("$build_dir/ref");
our @vortex_args = ("$spec2000_ref/lendian1.raw", "$spec2000_ref/lendian2.raw", "$spec2000_ref/lendian3.raw");
our @cc1_args = ("$spec2000_ref/166.i -o $spec2000_ref/166.s", "$spec2000_ref/200.i -o $spec2000_ref/200.s", "$spec2000_ref/expr.i -o $spec2000_ref/expr.s", "$spec2000_ref/integrate.i -o $spec2000_ref/integrate.s", "$spec2000_ref/scilab.i -o $spec2000_ref/scilab.s");
our @crafty_args = (" < $spec2000_ref/crafty.in");
our @eon_args = ("$spec2000_ref/chair.control.cook $spec2000_ref/chair.camera $spec2000_ref/chair.surfaces $spec2000_ref/chair.cook.ppm ppm $spec2000_ref/pixels_out.cook", "$spec2000_ref/chair.control.rushmeier $spec2000_ref/chair.camera $spec2000_ref/chair.surfaces $spec2000_ref/chair.rushmeier.ppm ppm $spec2000_ref/pixels_out.rushmeier", "$spec2000_ref/chair.control.kajiya $spec2000_ref/chair.camera $spec2000_ref/chair.surfaces $spec2000_ref/chair.kajiya.ppm ppm $spec2000_ref/pixels_out.kajiya");
our @gap_args = (" -l $spec2000_all -q -m 192M < $spec2000_ref/ref.in");
our @perlbmk_args = ("-I$spec2000_all/lib $spec2000_all/diffmail.pl 2 550 15 24 23 100", "-I$spec2000_all -I$spec2000_all/lib $spec2000_ref/makerand.pl", "-I$spec2000_all/lib $spec2000_all/perfect.pl b 3 m 4", "-I$spec2000_all/lib $spec2000_ref/splitmail.pl 850 5 19 18 1500", "-I$spec2000_all/lib $spec2000_ref/splitmail.pl 704 12 26 16 836", "-I$spec2000_all/lib $spec2000_ref/splitmail.pl 535 13 25 24 1091", "-I$spec2000_all/lib $spec2000_ref/splitmail.pl 957 12 23 26 1014");

our @twolf_small_args = ("$spec2000_test/test");
our @perlbmk_small_args = ("$spec2000_test/arith.t");
our @eon_small_args = ("$spec2000_test/chair.control.cook $spec2000_test/chair.camera $spec2000_test/chair.surfaces $spec2000_test/chair.cook.ppm ppm $spec2000_test/pixels_out.cook");
our @gap_small_args = (" -l $spec2000_ref -q -m 192M < $spec2000_test/gap.test.in");
our @vpr_small_args = ("$spec2000_test/net.in $spec2000_test/arch.in /tmp/place.out /tmp/dum.out -nodisp -place_only -init_t 5 -exit_t 0.005 -alpha_t 0.9412 -inner_num 2");
our @mcf_small_args = ("$spec2000_test/inp.in");
our @vortex_small_args = ("$spec2000_test/lendian1.raw", "$spec2000_test/lendian2.raw", "$spec2000_test/lendian3.raw");
our @gzip_small_args = ("", "$spec2000_test/input.compressed");
our @bzip2_small_args = ("", "$spec2000_test/input.random");


$args{"spec2000.mcf"} = \@mcf_args;
$args{"spec2000.bzip2"} = \@bzip2_args;
$args{"spec2000.gzip"} = \@gzip_args;
$args{"spec2000.parser"} = \@parser_args;
$args{"spec2000.twolf"} = \@twolf_args;
$args{"spec2000.vpr"} = \@vpr_args;
$args{"spec2000.crafty"} = \@crafty_args;
$args{"spec2000.cc1"} = \@cc1_args;
$args{"spec2000.eon"} = \@eon_args;
$args{"spec2000.perlbmk"} = \@perlbmk_args;
$args{"spec2000.gap"} = \@gap_args;
$args{"spec2000.vortex"} = \@vortex_args;

$small_args{"spec2000.twolf"} = \@twolf_small_args;
$small_args{"spec2000.perlbmk"} = \@perlbmk_small_args;
$small_args{"spec2000.eon"} = \@eon_small_args;
$small_args{"spec2000.gap"} = \@gap_small_args;
$small_args{"spec2000.vpr"} = \@vpr_small_args;
$small_args{"spec2000.mcf"} = \@mcf_small_args;
$small_args{"spec2000.gzip"} = \@gzip_small_args;
$small_args{"spec2000.bzip2"} = \@bzip2_small_args;
$small_args{"spec2000.vortex"} = \@vortex_small_args;

spec_args_patsubst(\@all_specs2000, $cint2000, "spec2000", \%args, $spec2000_ref, "ref");
spec_args_patsubst(\@all_specs2000, $cint2000, "spec2000", \%args, $spec2000_all, "all");
spec_args_patsubst(\@all_specs2000, $cint2000, "spec2000", \%small_args, $spec2000_test, "test");
spec_args_patsubst(\@all_specs2000, $cint2000, "spec2000", \%small_args, $spec2000_all, "all");

$prep_commands{"spec2000.parser"} = "cp -r $cint2000/197.parser/data/all/input/2.1.dict.mod $cint2000/197.parser/data/all/input/words .";
$prep_commands{"spec2000.perlbmk"} = "cp -r $cint2000/253.perlbmk/data/all/input/lenums $cint2000/253.perlbmk/data/all/input/benums $cint2000/253.perlbmk/data/all/input/cpu2000_mhonarc.rc .";
$prep_commands{"spec2000.vortex"} = "cp -r $cint2000/255.vortex/data/ref/input/bendian1.raw $cint2000/255.vortex/data/ref/input/bendian2.raw $cint2000/255.vortex/data/ref/input/bendian3.raw $cint2000/255.vortex/data/ref/input/bendian.rnv $cint2000/255.vortex/data/ref/input/bendian.wnv $cint2000/255.vortex/data/ref/input/lendian1.raw $cint2000/255.vortex/data/ref/input/lendian2.raw $cint2000/255.vortex/data/ref/input/lendian3.raw $cint2000/255.vortex/data/ref/input/lendian.rnv $cint2000/255.vortex/data/ref/input/lendian.rnv $cint2000/255.vortex/data/ref/input/lendian.wnv $cint2000/255.vortex/data/ref/input/persons.1k .";

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

sub is_spec2000_benchmark
{
  my $bench = shift;
  for my $spec (@all_specs2000) {
    my $specbench = spec_exec_name("spec2000", $spec);
    #print "bench $bench spec $spec specbench $specbench\n";
    return 1 if ($bench eq $specbench);
  }
  return 0;
}



1;
