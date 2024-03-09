# This Perl script is used to automate the process of compiling, building, and running RTL simulations along with co-simulated model runs

## Step 1 (Modules Import): The script begins by importing necessary Perl modules including 
### strict, warnings, and Getopt::Long, which is used for parsing command-line options.

#!/usr/bin/perl -w
use strict;
use warnings;
use Getopt::Long qw(GetOptions);

## Step 2 (Default Variable Initialization): Several variables are initialized with default values. 
### These include $sim_mode, $test_name, and $regress_mode.

my $sim_mode  = 0;
my $test_name = "alu_ops_stress";
my $regress_mode = 0;
my $help;

## Step 3 (Command-line Options Parsing): The GetOptions function parses the command-line options passed to the script. 
### These options include -help, -sim_mode, -test, and -regress. The corresponding variables are updated based on the provided options.

GetOptions (
    'help'          =>  \$help,
    'sim_only=i'    =>  \$sim_mode,
    'test=s'        =>  \$test_name,
    'regress'       =>  \$regress_mode
);

my $usage =<<USAGE;

This script is used to compile, build and run RTL simulations
along with the co-simulated model runs. The script compiles
the C-model and copies the generated so file to the lib/ dir.
If this goes fine, then the RTL is compiled and simulation
starts. 
You can pass the following options to the script - 
  -help                => Prints this message
  -sim_mode = <value>  => To run in simulation mode only i.e. RTL won't be compiled
  -test = <name>       => Pass the test name to both model and RTL
  -regress = <value>   => Use this flag to tell the script we are in regress mode

USAGE

if ($help) {
    print $usage;
    exit;
}

## Stpe 4-1: We only need to copy the hex files when we are not in regress mode.
### If not in regress mode ($regress_mode is false), 
#### the script determines a directory name based on the provided test name and copies corresponding hex files from a specified directory to the current directory.
##  Stpe 4-2: As in regress mode the script is provided with the complete path of the hex files.

if (!$regress_mode) {
    my $dir_name = $test_name;
    if ($dir_name =~ /basic/) {
      $dir_name =~ s/_basic//;
    }
    elsif ($dir_name =~ /stress/) {
      $dir_name =~ s/_stress//;
    }
    # Get the test from hex-gen
    print ("cp ../hex_gen/tests/rand_$dir_name/hex/$test_name* ");
    system ("cp ../hex_gen/tests/rand_$dir_name/hex/$test_name* .");
}
## Step 5 (Compilation of ISS (Instruction Set Simulator) first):
### The script changes the directory to '../iss' and attempts to compile the ISS by running make iss. 
### If the compilation fails, it prints an error message and exits. Otherwise, it copies the generated iss.so file to a specified directory.
chdir '../iss';
print ("make iss\n");
if (system ("make iss")) {
    print "Make failed..! Exiting!\n";
    exit;
}
else {
    # Copy the iss.so file to the main directory
    if (!(-d "../mips-single-cycle/lib")) {
      system ("mkdir ../mips-single-cycle/lib");
    }
    print ("cp iss.so ../mips-single-cycle/lib/\n");
    system ("cp iss.so ../mips-single-cycle/lib/");
    ## Step 6(Compilation of RTL (Register Transfer Level) Code):
    ### If $sim_mode is 0 (indicating simulation mode is enabled), 
    ### the script removes existing simulation files, creates a working directory, and compiles Verilog files using the vlog command.
    chdir "../mips-single-cycle";
    if ($sim_mode eq 0) {
        print ("rm -rf vsim.wlf wlf* transcript work/\n");
        system ("rm -rf vsim.wlf wlf* transcript work/");
        print ("vlib work\n");
        system ("vlib work");
        print ("vlog testbench/* verilog/*\n");
        system ("vlog testbench/* verilog/*");
    }
    ## Step 7(Simulation Execution): 
    ### The script runs the simulation using the vsim command, specifying the testbench (top_tb), shared library for SystemVerilog (lib/iss), and a do-file to execute simulation commands. 
    ### The simulation output is redirected to a log file.
    print ("vsim -c top_tb -sv_lib lib/iss -do \"run -all; exit\" +test=$test_name  | tee sim.log");
    system ("vsim -c top_tb -sv_lib lib/iss -do \"run -all; exit\" +test=$test_name | tee sim.log");
    system ("rm -rf vsim.wlf wlf* transcript");
    # Remove the test from the current dir
    # if we are not in the regress mode
    
    ## Step 8(Cleanup): After simulation, temporary simulation files and optionally test-related files (if not in regress mode) are removed.
    if (!$regress_mode) {
        system ("rm -rf $test_name.hex $test_name\_pc.hex");
    }
}
