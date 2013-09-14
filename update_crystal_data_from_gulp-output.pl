#!/usr/bin/perl

#Author: Ankoor Patel#Date: 6/2/07
#Purpose: Creates a space delimited file containing the structure data from gulp simulations
#               
BEGIN {
push @INC,"/home/ap1702/lib/perl5";
}
use Math::MatrixReal;
use Math::Complex;
use Math::Trig;
use Getopt::Long;

my $crystal_data = 'crystal_data';
my $selected_file = '';
GetOptions (  "data_file|o=s" =>\$crystal_data,
              "results_file|i=s" =>\$selected_file);

print "\nyour current working directory is ";
system("pwd");

#Start reading files and making new inputs



# open the file
print "processing $selected_file\n";
open(RESFILE, $selected_file) or die "no results file selected, use option -i";
open RESULTS, ">>results";

$n = 0;
$defect = 0;
$preserved_angles = "yes";

%formula_list = ();
@results = ();
LINES_LOOP: while (<RESFILE>) {
	
	if (/Output for configuration/) {
		$n = 1;
	} elsif (/Comparison of initial and final structures/) {
		if ($version == "conp") {
#			print "$version\n";
			$n = 2;
		}
	} elsif (/Elastic Constant Matrix/){
		$n = 4;
	} elsif (/Elastic Compliance Matrix/) {
	    $n = 5;
                if ((($alpha_percent*$alpha_percent)>0.01)||(($beta_percent*$beta_percent)>0.01)||(($gamma_percent*$gamma_percent)>0.01)) {
                        $preserved_angles = "no";
                } else {
                        $preserved_angles = "yes";
						}
		$result = "$selected_file  $title  $sim_name  $formula  preserved_angles $preserved_angles $latt_E  ";
		if ($version == "conp") {
					$elastic_matrix = Math::MatrixReal->new_from_string(<<"MATRIX");
[ $c11 $c12 $c13 $c14 $c15 $c16 ]
[ $c21 $c22 $c23 $c24 $c25 $c26 ]
[ $c31 $c32 $c33 $c34 $c35 $c36 ]
[ $c41 $c42 $c43 $c44 $c45 $c46 ]
[ $c51 $c52 $c53 $c54 $c55 $c56 ]
[ $c61 $c62 $c63 $c64 $c65 $c66 ]
MATRIX
			$elastic_matrix_amu = $elastic_matrix->shadow(); 
			$elastic_matrix_amu -> multiply_scalar($elastic_matrix,0.062415097400);
			$elastic_inverse = $elastic_matrix_amu->inverse;
			$isothermal_compressibilty = 0;
			for ($i=1;$i<=3;$i++) {
			for ($j=1;$j<=3;$j++) {
			$isothermal_compressibilty =+ $elastic_inverse->element($i,$j);
			}
			}

			$result = "$result"."%VOL  $vol_percent  %A $a_percent  %B $b_percent  %C  $c_percent  %alpha  $alpha_percent  %beta  $beta_percent  %gamma  $gamma_percent  c11  $c11  c12  $c12  c13  $c13  c22  $c22  c33  $c33  c44  $c44  c55  $c55  c66  $c66  ISO_T_COMP $isothermal_compressibilty ";
			$result_extra = "VOL  $vol_init  $vol_final  $vol_diff  A  $a_init  $a_final  $a_diff  B  $b_init  $b_final  $b_diff  C  $c_init  $c_final  $c_diff  ALPHA  $alpha_init  $alpha_final  $alpha_diff  BETA  $beta_init  $beta_final  $beta_diff  GAMMA  $gamma_init  $gamma_final  $gamma_diff  ";
		}
		if ($defect == 0) {
		                if ((($alpha_percent*$alpha_percent)>0.01)||(($beta_percent*$beta_percent)>0.01)||(($gamma_percent*$gamma_percent)>0.01)) {
                        $preserved_angles = "no";
                } else {
                        $preserved_angles = "yes";
						}
			$result = "$result"."$result_extra"."\n";
#			push (@results, $result);
			print RESULTS "$result";
### This resets all variables
#			$result = ();
#			$preserved_angles = "yes";
#			$title  = ();
#			$sim_name  = ();
#			$preserved_angles  = ();
#			$latt_E = ();
#			$vol_percent  = ();
#			$a_percent  = ();
#			$b_percent  = ();
#			$c_percent  = ();
#			$alpha_percent  = ();
#			$beta_percent  = ();
#			$gamma_percent  = ();
#			$result_extra  = ();
#			$vol_init  = ();
#			$vol_final  = ();
#			$vol_diff  = ();
#			$a_init  = ();
#			$a_final   = ();
#			$a_diff   = ();
#			$b_init   = ();
#			$b_final   = ();
#			$b_diff   = ();
#			$c_init   = ();
#			$c_final  = ();
#			$c_diff  = ();
#			$alpha_init = ();
#			$alpha_final  = ();
#			$alpha_diff  = ();
#			$beta_init  = ();
#			$beta_final  = ();
#			$beta_diff = ();
#			$gamma_init  = ();
#			$gamma_final = ();
#			$gamma_diff  = ();     
#			$c11 = ();
#			$c12 = ();
#			$c13 = ();
#			$c22 = ();
#			$c33 = ();
#			$c44 = ();
#			$c55 = ();
#			$c66 = ();			
                }
	} elsif (/Defect calculation for configuration/) {
		$n = 3;
	} elsif (/Final coordinates of region 1/) {
		if ($defect == 1) {

#			$result = "$result"."DEFECT_E  $defect_E  $defect_elem  $defect_type  $defect_x  $defect_y  $defect_z";
                        $result = "$result"."DEFECT_E  $defect_E  DEFECT_CHARGE $defect_charge ";
                        $result = "$result"."$result_extra"."\n";
#			push (@results, $result);
			print RESULTS "$result";
### This resets all variables
#			$result = ();
#			$preserved_angles = "true";
#			$title  = ();
#			$sim_name  = ();
#			$preserved_angles  = ();
#			$latt_E = ();
#			$vol_percent  = ();
#			$a_percent  = ();
#			$b_percent  = ();
#			$c_percent  = ();
#			$alpha_percent  = ();
#			$beta_percent  = ();
#			$gamma_percent  = ();
#			$result_extra  = ();
#			$vol_init  = ();
#			$vol_final  = ();
#			$vol_diff  = ();
#			$a_init  = ();
#			$a_final   = ();
#			$a_diff   = ();
#			$b_init   = ();
#			$b_final   = ();
#			$b_diff   = ();
#			$c_init   = ();
#			$c_final  = ();
#			$c_diff  = ();
#			$alpha_init = ();
#			$alpha_final  = ();
#			$alpha_diff  = ();
#			$beta_init  = ();
#			$beta_final  = ();
#			$beta_diff = ();
#			$gamma_init  = ();
#			$gamma_final = ();
#			$gamma_diff  = ();                  
#			$c11 = ();
#			$c12 = ();
#			$c13 = ();
#			$c22 = ();
#			$c33 = ();
#			$c44 = ();
#			$c55 = ();
#			$c66 = ();
		}
	} elsif (/Timing analysis for Gulp/) {
		last LINES_LOOP;
	}

	if ($n == 0) {
		if (/constant volume calculation/) {
			$version = "conv";
		}
		if (/constant pressure calculation/) {
			$version = "conp";
		}
		if (/perform defect calculation after bulk run/) {
			$defect = 1;
		}
		if (/ (\S+\@\S+)\s+/) {
			$title = $1;
		}
		if (/Input for Configuration =   (\d+)/) {
			$input_no = $1;
		}
		if (/Formula = (\S+)/) {
			$formula_list{$input_no} = $1;
		}


	} elsif ($n == 1) {
		if (/Output for configuration   (\d*)/) {
			$output_no = $1;
			$formula = $formula_list{$output_no};
		}
			if (/Output for configuration\s+(\d+) : (\S+)\s+/) {
			$sim_name = $2;
#			print "$sim_name\n";
		}
		if (/Final energy =\s+([-\d\.]+)/) {
			$latt_E = "LATT_Energy ".$1;
		} elsif(/Final enthalpy =\s+([-\d\.]+)/) {
			$latt_E = "LATT_Enthalpy ".$1;
		}
	} elsif ($n == 2) {
#	ATOM POSITION CODE:
#		if (/\s1\s\s$RE[\D]+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
#			$REx = $1;
#			$REy = $2;
#			$REz = $3;
#		} elsif (/\s5\s\s$B_site[\D]+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
#			$Bx = $1;
#			$By = $2;
#			$Bz = $3;
#		} elsif (/\s9\s\sO[\D]+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
#			$O1x = $1;
#			$O1y = $2;
#			$O1z = $3;
#		} elsif (/\s13\s\sO[\D]+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
#			$O2x = $1;
#			$O2y = $2;
#			$O2z = $3;
#		} 
		CELL_LOOP: if (/Volume\s*([-\d\.]+)\s*([-\d\.]+)\s*([-\d\.]+)\s*Angs..3\s*([-\d\.]+)/) {
		# Get the cell information
			$vol_init = $1;
			$vol_final = $2;
			$vol_diff = $3;
			$vol_percent = $4;
			next LINES_LOOP;
		} elsif (/a\s*([-\d\.]+)\s*([-\d\.]+)\s*([-\d\.]+)\s*Angstroms\s*([-\d\.]+)/) {
			$a_init = $1;
			$a_final = $2;
			$a_diff = $3;
			$a_percent = $4;
			next LINES_LOOP;
		} elsif (/b\s*([-\d\.]+)\s*([-\d\.]+)\s*([-\d\.]+)\s*Angstroms\s*([-\d\.]+)/) {
			$b_init = $1;
			$b_final = $2;
			$b_diff = $3;
			$b_percent = $4;
			next LINES_LOOP;
		} elsif (/c\s*([-\d\.]+)\s*([-\d\.]+)\s*([-\d\.]+)\s*Angstroms\s*([-\d\.]+)/) {
			$c_init = $1;
			$c_final = $2;
			$c_diff = $3;
			$c_percent = $4;
			next LINES_LOOP;
		} elsif (/alpha\s*([-\d\.]+)\s*([-\d\.]+)\s*([-\d\.]+)\s*Degrees\s*([-\d\.]+)/) {
			$alpha_init = $1;
			$alpha_final = $2;
			$alpha_diff = $3;
			$alpha_percent = $4;
			next LINES_LOOP;
		} elsif (/beta\s*([-\d\.]+)\s*([-\d\.]+)\s*([-\d\.]+)\s*Degrees\s*([-\d\.]+)/) {
			$beta_init = $1;
			$beta_final = $2;
			$beta_diff = $3;
			$beta_percent = $4;
			next LINES_LOOP;
		} elsif (/gamma\s*([-\d\.]+)\s*([-\d\.]+)\s*([-\d\.]+)\s*Degrees\s*([-\d\.]+)/) {
			$gamma_init = $1;
			$gamma_final = $2;
			$gamma_diff = $3;
			$gamma_percent = $4;
			next LINES_LOOP;
		}
	}  elsif ($n == 4) {
	ELASTIC_LOOP: if (/\s+1\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
			$c11 = $1;
			$c12 = $2;
			$c13 = $3;
			$c14 = $4;
			$c15 = $5;
			$c16 = $6;
		} elsif (/\s+2\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
			$c21 = $1;
			$c22 = $2;
			$c23 = $3;
			$c24 = $4;
			$c25 = $5;
			$c26 = $6;
		} elsif (/\s+3\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
			$c31 = $1;
                        $c32 = $2;
			$c33 = $3;
			$c34 = $4;
			$c35 = $5;
			$c36 = $6;
		} elsif (/\s+4\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
			$c41 = $1;
			$c42 = $2;
			$c43 = $3;
			$c44 = $4;
			$c45 = $5;
			$c46 = $6;
		} elsif (/\s+5\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
			$c51 = $1;
			$c52 = $2;
			$c53 = $3;
			$c54 = $4;
			$c55 = $5;
			$c56 = $6;
		} elsif (/\s+6\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
			$c61 = $1;
			$c62 = $2;
			$c63 = $3;
			$c64 = $4;
			$c65 = $5;
			$c66 = $6;
		}
	}  elsif ($n == 3) {
	# Get the defect energies etc.
		if (/Total charge on defect\s+=\s+([-\d\.]+)/) {
                $defect_charge = $1;
                next LINES_LOOP;
                }
                
                if (/Final defect energy\s+=\s+([-\d\.]+)/) {
		$defect_E = $1;
		next LINES_LOOP;
		}
#		if (/1  (\w+)\s+(\w+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
#		$defect_elem = $1;
#		$defect_type = $2;
#		$defect_x = $3;
#		$defect_y = $4;
#		$defect_z = $5;
#		next LINES_LOOP;
#		}
	}

}
close RESULTS;
close RESFILE;



open (DVOL_DATA, "<$crystal_data") or die "$crystal_data not found\n";
@data = <DVOL_DATA>;
close DVOL_DATA;
system("mv $crystal_data $crystal_data.bak");

$opt = 0;
for ($n = 0; $n <= scalar(@data); $n++) {
	if ($data[$n] =~ /END/) {
		$opt = 0;
	} elsif ($data[$n] =~ /cell/) {
		$data[$n+1]= "$a_final $b_final $c_final $alpha_final $beta_final $gamma_final\n";
	} elsif ($data[$n] =~ /size/) {
		$size = $data[$n];
	} elsif ($data[$n] =~ /cascade_initial_settings/) {
		$opt = "cascade_initial_settings";
	} elsif ($data[$n] =~ /gulp_keywords/) {
	} elsif ($data[$n] =~ /gulp_output/) {
		$opt = "gulp_output";
	} elsif ($data[$n] =~ /cascade_final_settings/) {
		$opt = "cascade_final_settings";
	} elsif ($data[$n] =~ /title/) {
		$sim_title = $data[$n+1];
	} elsif ($data[$n] =~ /fractional/) {
		$opt = "fractional";
	} elsif ($data[$n] =~ /defects/) {
		$opt = "defects";
	} elsif ($data[$n] =~ /persistent/) {
		$opt = "persistent";
	} elsif ($data[$n] =~ /space/) {
		$space = "space\n".$data[$n+1];
	} elsif ($data[$n] =~ /elastic_constants/) {
		$opt = "elastic_constants";
	} elsif ($data[$n] =~ /offset_vectors/) {
		$opt = "offset_vectors";
	} elsif ($data[$n] =~ /shell_ions/) {
		$shel_ions = $data[$n+1];
	} elsif ($data[$n] =~ /volume_changes/) {
		@volumes = $data[$n+1];
	}
	
	if ($opt =~ /cascade_initial_settings/) {
	} elsif ($opt =~ /cascade_final_settings/) {
	} elsif ($opt =~ /gulp_output/) {
	} elsif ($opt =~ /fractional/) {
	} elsif ($opt =~ /defects/) {
	} elsif ($opt =~ /persistent/) {
	} elsif ($opt =~ /elastic_constants/) {
          $data[$n+1] = "$c11 $c12 $c13 $c14 $c15 $c16\n";
          $data[$n+2] = "$c21 $c22 $c23 $c24 $c25 $c26\n";          
          $data[$n+3] = "$c31 $c32 $c33 $c34 $c35 $c36\n";
          $data[$n+4] = "$c41 $c42 $c43 $c44 $c45 $c46\n";
          $data[$n+5] = "$c51 $c52 $c53 $c54 $c55 $c56\n";
          $data[$n+6] = "$c61 $c62 $c63 $c64 $c65 $c66\n";
          
          $opt = 0; 
        } elsif ($opt =~ /offset_vectors/) {
	}
	
}


open (DVOL_DATA, ">$crystal_data") or die "$crystal_data not found\n";
foreach $line (@data) {print DVOL_DATA $line;}
close DVOL_DATA; 
