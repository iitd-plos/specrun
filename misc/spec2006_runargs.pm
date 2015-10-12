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
our @cactusADM_args = ("$spec2006_ref/benchADM.par");
our @GemsFDTD_args = ("");
our @omnetpp_args = ("$spec2006_ref/omnetpp.ini");
our @perlbmk_args = ("-I$spec2006_all/lib $spec2006_ref/checkspam.pl 2500 5 25 11 150 1 1 1 1", "-I$spec2006_all/lib $spec2006_all/diffmail.pl 4 800 10 17 19 300", "-I$spec2006_all/lib $spec2006_all/splitmail.pl 1600 12 26 16 4500");
our @bwaves_args = ("");
our @gamess_args = ("< $spec_ref/cytosine.2.config", "< $spec_ref/h2ocu2+.gradient.config", "< $spec_ref/triazolium.config");

$args{"spec2006.mcf"} = \@mcf_args;
$args{"spec2006.bzip2"} = \@bzip2_args;
$args{"spec2006.cactusADM"} = \@cactusADM_args;
$args{"spec2006.GemsFDTD"} = \@GemsFDTD_args;
$args{"spec2006.omnetpp"} = \@omnetpp_args;
$args{"spec2006.perlbmk"} = \@perlbmk_args;
$args{"spec2006.bwaves"} = \@bwaves_args;
$args{"spec2006.gamess"} = \@gamess_args;

$prepcmd{"spec2006.gamess"} = "cp $spec_ref/cytosine.2.inp $spec_ref/h2ocu2+.gradient.inp $spec_ref/triazolium.inp .";

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
