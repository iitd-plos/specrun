#!/usr/bin/perl -w
use strict;
use warnings;
use Switch;
use config_host;
use spec_common;
our (%args, %small_args);

our $build_dir;

our @all_specs2006 = ("464.h264ref", "458.sjeng", "483.xalancbmk", "481.wrf", "470.lbm", "456.hmmer", "435.gromacs", "434.zeusmp", "403.gcc", "459.GemsFDTD", "444.namd", "437.leslie3d", "401.bzip2", "400.perlbench", "416.gamess", "473.astar", "465.tonto", "447.dealII", "462.libquantum", "450.soplex", "454.calculix", "429.mcf", "410.bwaves", "482.sphinx3", "453.povray", "445.gobmk", "436.cactusADM", "999.specrand", "998.specrand", "471.omnetpp", "433.milc");

our $cpu2006 = "$build_dir/installs/cpu2006";
our $cint2006 = "$cpu2006/benchspec/CPU2006";

our $spec2006_dir = "$build_dir/spec2006";
our $spec2006_ref = "$spec2006_dir/ref";
our $spec2006_all = "$spec2006_dir/all";
our $spec2006_test = "$spec2006_dir/test";


our @bzip2_args = ("$spec2006_ref/input.source 280", "$spec2006_ref/chicken.jpg 30", "$spec2006_ref/liberty.jpg 30", "$spec2006_all/input.program 280", "$spec2006_ref/text.html 280", "$spec2006_all/input.combined 200");
our @mcf_args = ("$spec2006_ref/inp.in");
#our @gzip_args = ("$spec2006_ref/input.source 60", "$spec2006_ref/input.graphic 60", "$spec2006_ref/input.program 60", "$spec2006_ref/input.random 60", "$spec2006_ref/input.log 60");
#our @parser_args =("2.1.dict.mod -batch < $spec2006_ref/ref.in > /tmp/out");
#our @vpr_args = ("$spec2006_ref/net.in $spec2006_ref/arch.in /tmp/place.out /tmp/dum.out -nodisp -place_only -init_t 5 -exit_t 0.005 -alpha_t 0.9412 -inner_num 2", "$spec2006_ref/net.in $spec2006_ref/arch.in $spec2006_ref/place.in /tmp/route.out -nodisp -route_only -route_chan_width 15 -pres_fac_mult 2 -acc_fac 1 -first_iter_pres_fac 4 -initial_pres_fac 8");
#our @twolf_args = ("$build_dir/ref");
#our @vortex_args = ("$spec2006_ref/lendian1.raw", "$spec2006_ref/lendian2.raw", "$spec2006_ref/lendian3.raw");
#our @cc1_args = ("$spec2006_ref/166.i -o $spec2006_ref/166.s", "$spec2006_ref/200.i -o $spec2006_ref/200.s", "$spec2006_ref/expr.i -o $spec2006_ref/expr.s", "$spec2006_ref/integrate.i -o $spec2006_ref/integrate.s", "$spec2006_ref/scilab.i -o $spec2006_ref/scilab.s");
#our @crafty_args = (" < $spec2006_ref/crafty.in");
#our @eon_args = ("$spec2006_ref/chair.control.cook $spec2006_ref/chair.camera $spec2006_ref/chair.surfaces $spec2006_ref/chair.cook.ppm ppm $spec2006_ref/pixels_out.cook", "$spec2006_ref/chair.control.rushmeier $spec2006_ref/chair.camera $spec2006_ref/chair.surfaces $spec2006_ref/chair.rushmeier.ppm ppm $spec2006_ref/pixels_out.rushmeier", "$spec2006_ref/chair.control.kajiya $spec2006_ref/chair.camera $spec2006_ref/chair.surfaces $spec2006_ref/chair.kajiya.ppm ppm $spec2006_ref/pixels_out.kajiya");
#our @gap_args = (" -l $spec2006_all -q -m 192M < $spec2006_ref/ref.in");
#our @perlbmk_args = ("-I$spec2006_all/lib $spec2006_all/diffmail.pl 2 550 15 24 23 100", "-I$spec2006_all -I$spec2006_all/lib $spec2006_ref/makerand.pl", "-I$spec2006_all/lib $spec2006_all/perfect.pl b 3 m 4", "-I$spec2006_all/lib $spec2006_ref/splitmail.pl 850 5 19 18 1500", "-I$spec2006_all/lib $spec2006_ref/splitmail.pl 704 12 26 16 836", "-I$spec2006_all/lib $spec2006_ref/splitmail.pl 535 13 25 24 1091", "-I$spec2006_all/lib $spec2006_ref/splitmail.pl 957 12 23 26 1014");
#
#our @twolf_small_args = ("$spec2006_test/test");
#our @perlbmk_small_args = ("$spec2006_test/arith.t");
#our @eon_small_args = ("$spec2006_test/chair.control.cook $spec2006_test/chair.camera $spec2006_test/chair.surfaces $spec2006_test/chair.cook.ppm ppm $spec2006_test/pixels_out.cook");
#our @gap_small_args = (" -l $spec2006_ref -q -m 192M < $spec2006_test/gap.test.in");
#our @vpr_small_args = ("$spec2006_test/net.in $spec2006_test/arch.in /tmp/place.out /tmp/dum.out -nodisp -place_only -init_t 5 -exit_t 0.005 -alpha_t 0.9412 -inner_num 2");
#our @mcf_small_args = ("$spec2006_test/inp.in");
#our @vortex_small_args = ("$spec2006_test/lendian1.raw", "$spec2006_test/lendian2.raw", "$spec2006_test/lendian3.raw");
#our @gzip_small_args = ("", "$spec2006_test/input.compressed");
#our @bzip2_small_args = ("", "$spec2006_test/input.random");


$args{"spec2006.mcf"} = \@mcf_args;
$args{"spec2006.bzip2"} = \@bzip2_args;
#$args{"spec2006.gzip"} = \@gzip_args;
#$args{"spec2006.parser"} = \@parser_args;
#$args{"spec2006.twolf"} = \@twolf_args;
#$args{"spec2006.vpr"} = \@vpr_args;
#$args{"spec2006.crafty"} = \@crafty_args;
#$args{"spec2006.cc1"} = \@cc1_args;
#$args{"spec2006.eon"} = \@eon_args;
#$args{"spec2006.perlbmk"} = \@perlbmk_args;
#$args{"spec2006.gap"} = \@gap_args;
#$args{"spec2006.vortex"} = \@vortex_args;

#$small_args{"spec2006.twolf"} = \@twolf_small_args;
#$small_args{"spec2006.perlbmk"} = \@perlbmk_small_args;
#$small_args{"spec2006.eon"} = \@eon_small_args;
#$small_args{"spec2006.gap"} = \@gap_small_args;
#$small_args{"spec2006.vpr"} = \@vpr_small_args;
#$small_args{"spec2006.mcf"} = \@mcf_small_args;
#$small_args{"spec2006.gzip"} = \@gzip_small_args;
#$small_args{"spec2006.bzip2"} = \@bzip2_small_args;
#$small_args{"spec2006.vortex"} = \@vortex_small_args;

sub is_spec2006_benchmark
{
  my $bench = shift;
  for my $spec (@all_specs2006) {
    return 1 if ($bench eq spec_exec_name($spec));
  }
  return 0;
}

spec_args_patsubst(\@all_specs2006, $cint2006, "spec2006", \%args, $spec2006_ref, "ref");
spec_args_patsubst(\@all_specs2006, $cint2006, "spec2006", \%args, $spec2006_all, "all");
spec_args_patsubst(\@all_specs2006, $cint2006, "spec2006", \%small_args, $spec2006_test, "test");
spec_args_patsubst(\@all_specs2006, $cint2006, "spec2006", \%small_args, $spec2006_all, "all");


1;
