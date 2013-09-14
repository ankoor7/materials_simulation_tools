#!/usr/bin/perl

#Author: Ankoor Patel#Date: 6/2/07
#Purpose: Creates a space delimited file containing the structure data from gulp simulations
#               
print "\nyour current working directory is ";
system("pwd");

#Start reading files and making new inputs
open RESULTS, ">>results";
open PHON_RESULTS, ">>phon_results";
FILE_LOOP: foreach my $selected_file (glob "*.o*"){

# open the file
print "processing $selected_file\n";
open(RESFILE, $selected_file);


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
		$n = 2;
		}
	} elsif (/Phonon Calculation/) {
		$n = 4;
	}  elsif (/High frequency refractive indices/) {
                if ((($alpha_percent*$alpha_percent)>0.01)||(($beta_percent*$beta_percent)>0.01)||(($gamma_percent*$gamma_percent)>0.01)) {
                        $preserved_angles = "no";
                } else {
                        $preserved_angles = "yes";
						}
		$result = "$selected_file  $title  $sim_name  $formula  preserved_angles $preserved_angles $latt_E  ";
		if ($version == "conp") {
			$result = "$result"."%VOL  $vol_percent  %A $a_percent  %B $b_percent  %C  $c_percent  %alpha  $alpha_percent  %beta  $beta_percent  %gamma  $gamma_percent  ";
			$result_extra = "VOL  $vol_init  $vol_final  $vol_diff  A  $a_init  $a_final  $a_diff  B  $b_init  $b_final  $b_diff  C  $c_init  $c_final  $c_diff  ALPHA  $alpha_init  $alpha_final  $alpha_diff  BETA  $beta_init  $beta_final  $beta_diff  GAMMA  $gamma_init  $gamma_final  $gamma_diff  ";
		}
		if ($defect == 0) {
                  if ((($alpha_percent*$alpha_percent)>0.01)||(($beta_percent*$beta_percent)>0.01)||(($gamma_percent*$gamma_percent)>0.01)) {
                        $preserved_angles = "no";
                  } else {
                        $preserved_angles = "yes";
                  }
			$result = "$result"."$result_extra"."\n";
			print RESULTS "$result";
			if ($intensity == 1){
				print PHON_RESULTS "$result\n";
		}

			$result = ();
			$preserved_angles = "yes";
			$title  = $sim_name = $preserved_angles =  $latt_E = $vol_percent  = 	$a_percent  = $b_percent  =$c_percent  = $alpha_percent  = $beta_percent  =$gamma_percent  = $result_extra  = 	$vol_init  = $vol_final  =$vol_diff  = $a_init  = $a_final   = $a_diff   = $b_init   = $b_final   = $b_diff   = $c_init   = $c_final  = $c_diff  = $alpha_init = $alpha_final  =	$alpha_diff  = $beta_init  = $beta_final  = $beta_diff = $gamma_init  = $gamma_final =	$gamma_diff  = ();                  
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
			$result = ();
			$preserved_angles = "true";
			$title  = ();
			$sim_name  = ();
			$preserved_angles  = ();
			$latt_E = ();
			$vol_percent  = ();
			$a_percent  = ();
			$b_percent  = ();
			$c_percent  = ();
			$alpha_percent  = ();
			$beta_percent  = ();
			$gamma_percent  = ();
			$result_extra  = ();
			$vol_init  = ();
			$vol_final  = ();
			$vol_diff  = ();
			$a_init  = ();
			$a_final   = ();
			$a_diff   = ();
			$b_init   = ();
			$b_final   = ();
			$b_diff   = ();
			$c_init   = ();
			$c_final  = ();
			$c_diff  = ();
			$alpha_init = ();
			$alpha_final  = ();
			$alpha_diff  = ();
			$beta_init  = ();
			$beta_final  = ();
			$beta_diff = ();
			$gamma_init  = ();
			$gamma_final = ();
			$gamma_diff  = ();                  
		}
	} #elsif (/Timing analysis for Gulp/) {
	#	last LINES_LOOP;
	#}

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
		if (/calculate phonon eigenvectors and estimate IR intensities/) {
			$intensity = 1;
		}
		if (/calculate phonons for final geometry/) {
			$phonon = 1;
		}
		if (/ (\S+@\S+)\s+/) {
			$title = $1;
		}
		if (/Input for Configuration =\s+(\d+)/) {
			$input_no = $1;
		}
		if (/Formula = (\S+)/) {
			$formula_list{$input_no} = $1;
		}


	} elsif ($n == 1) {
		if (/Output for configuration\s+(\d*)/) {
			$output_no = $1;
			$formula = $formula_list{$output_no};
		}
			if (/Output for configuration\s+(\d+) : (\S+)\s+/) {
			$sim_name = $2;
#			print "$sim_name\n";
		}
		if (/Final energy =\s+([-\d\.]+)/) {
			$latt_E = "Latt_Energy ".$1;
		} elsif (/Final enthalpy =\s+([-\d\.]+)/) {
                        $latt_E = "Latt_Enthalpy ".$1;
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
	} elsif ($n == 3) {
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
	}   elsif ($n == 4) {
		if (/Number of k points for this configuration =\s+([-\d\.]+)/) {
			print PHON_RESULTS "N_KPOINTS  $1\nFrequency  IR_Intensity  Raman_intensity  Total_intensity\n";
			}
		if (/Frequency\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
			$freq1 = $1;
            $freq2 = $2;
            $freq3 = $3;
            next LINES_LOOP;
            }
		if (/IR Intensity\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
			$inten1 = $1;
            $inten2 = $2;
            $inten3 = $3;
			next LINES_LOOP;
            }
		if (/Raman Intsty\s+([-\d\.]+)\s+([-\d\.]+)\s+([-\d\.]+)/) {
			$raman1 = $1;
            $raman2 = $2;
            $raman3 = $3;
			$sum1 = $inten1 + $raman1;
			$sum2 = $inten2 + $raman2;
			$sum3 = $inten3 + $raman3;
			print PHON_RESULTS "$freq1  $inten1 $raman1 $sum1\n$freq2  $inten2 $raman2 $sum2\n$freq3  $inten3 $raman3 $sum3\n";
			$freq1 = $inten1 = $raman1= $raman3= $raman2= $freq2  = $inten2 = $freq3 =  $inten3 ='';
			next LINES_LOOP;
            }

		next LINES_LOOP;
	}
}
close RESFILE;
}
#open RESULTS, ">>results";
#foreach $res (@results) {
#print RESULTS "$res";
#close RESULTS;
#}
close RESULTS;
close PHON_RESULTS;

