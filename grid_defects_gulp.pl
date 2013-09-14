#! /usr/bin/perl -w
#Author: Ankoor Patel
#Date: 6/2/07
#Purpose: Create GULP defect input files for a specific structure
#
BEGIN {
push @INC,"/home/ap1702/lib/perl5";
}
use Math::MatrixReal;
use Math::Complex;
use Math::Trig;
use Getopt::Long;

###################
###   OPTIONS   ###
###################
###################
my $n_defect_master = '';
my $bond_offset = -0.2;
my $bond_offset_species = '';
my $cluster_calcs = '';
my $opti_perfect = '';
my $opti_defect = '';
my $supercell_only = '';
GetOptions (  "bond_offset_species=s" =>\$bond_offset_species,
              "bond_offset=f" =>\$bond_offset,
              "opti_perfect" =>\$opti_perfect,
              "opti_defect" =>\$opti_defect,
			  "cluster_calcs=s" =>\$cluster_calcs,
			  "supercell" =>\$supercell_only);
####### SUBROUTINES ######
######################################################################################################################

## COORD CONVERSION ##
sub convert_fractional {
	$XYZ_coord=$_[3]->multiply(Math::MatrixReal->new_from_cols([[$_[0], $_[1], $_[2]]]));
}

sub XYZ_coord_norm {
	@info = split(/ +/,$_[0]);
	if (exists $info[4]) {
	$XYZ_norm=&convert_fractional($info[2], $info[3], $info[4],$_[1]);
#	$XYZ_norm=$_[1]->multiply(Math::MatrixReal->new_from_cols([[$info[2], $info[3], $info[4]]]));
	return sprintf("%s %s %.15f %.15f %.15f\n",$info[0], $info[1], $XYZ_norm->element(1,1), $XYZ_norm->element(2,1), $XYZ_norm->element(3,1));
	}
 }

 sub remove_duplicate_from_array{
    my @lists = @_;

    ## The array holds all the unique elements from list
    my @list_unique = ();

    ## Initial checker to remove duplicate
    my $checker = -12345645312;

    ## For each sorted elements from the array
    foreach my $list( sort( @lists ) ){

        ## move to next element if same
        if($checker == $list){
            next;
        }

        ## replace old one with new found value
        else{
            $checker = $list;
            push( @list_unique, $checker);
        }
    }

    ## Finally returns the array that contains unique elements
    return @list_unique;
}

## END SUBROUTINES
#########################################################################################################################
#########################################################################################################################


$IS_CASCADE=0;
$IS_GULP=0;
@pressures = 0;
@volumes = 0;

#This contains the charges, potentials and spring constants. Basically everything at the end of the input file.
if ( -e "potentials.cas") {
$IS_CASCADE=1;
$pot_file = "potentials.cas";
open (POTENTIALS, "<$pot_file");
@potentials = <POTENTIALS>;
close POTENTIALS;
} elsif (-e "potentials.glp") {
$IS_GULP=1;
$pot_file = "potentials.glp";
open (POTENTIALS, "<$pot_file");
@gulp_potentials = <POTENTIALS>;
close POTENTIALS;
}
chomp(@potentials);
chomp(@gulp_potentials);
open (DVOL_DATA, "<crystal_data") or die "crystal_data not found\n";
@data_raw = <DVOL_DATA>;
close DVOL_DATA;

# VARIABLES TO TIDY UP - THEY ARE CURRENTLY DEFINIED IN THE SCRIPT
#??

foreach $line (@data_raw) {
  $line =~ s%^\s+%%g;
  print $line;
  push (@data, $line);
}

$opt = 0;
CRYSTAL_DATA: for ($n = 0; $n <= scalar(@data); $n++) {
        if ($data[$n] =~ /END/) {
		$opt = 0;
	} elsif ($data[$n] =~ /cell/) {
		chomp($data[$n+1]);
		@cell_data = split(/ +/,$data[$n+1]);
	} elsif ($data[$n] =~ /size/) {
		$size = $data[$n];
	} elsif ($data[$n] =~ /cascade_initial_settings/) {
		$opt = "cascade_initial_settings";
	} elsif ($data[$n] =~ /gulp_keywords/) {
		chomp($gulp_keywords = $data[$n+1]);
	} elsif ($data[$n] =~ /gulp_output/) {
		$opt = "gulp_output";
	} elsif ($data[$n] =~ /cascade_final_settings/) {
		$opt = "cascade_final_settings";
	} elsif ($data[$n] =~ /title/) {
		$sim_title = $data[$n+1];
                chomp($sim_title);
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
		chomp($data[$n+1]);
		@shel_ions = split(/ +/,$data[$n+1]);
	} elsif ($data[$n] =~ /volume_changes/) {
		chomp($data[$n+1]);
		@volumes = split(/ +/,$data[$n+1]);
	} elsif ($data[$n] =~ /pressure_changes/) {
                chomp($data[$n+1]);
                @pressures = split(/ +/,$data[$n+1]);
        }

	if ($opt =~ /cascade_initial_settings/) {
		push(@settings,$data[$n]);
	} elsif ($opt =~ /cascade_final_settings/) {
		push(@final_settings,$data[$n]);
	} elsif ($opt =~ /gulp_output/) {
		push(@gulp_output,$data[$n]);
	} elsif ($opt =~ /fractional/) {
		push(@atom_coords,$data[$n]);
	} elsif ($opt =~ /defects/) {
		push(@defects_data,$data[$n]);
	} elsif ($opt =~ /persistent/) {
		push(@persistent_data,$data[$n]);
	} elsif ($opt =~ /elastic_constants/) {
		chomp ($data[$n]);
		push (@elastic_data,"$data[$n]");
	} elsif ($opt =~ /offset_vectors/) {
	   push (@offset_vectors,"$data[$n]");
	}

}

shift(@settings);
chomp(@settings);
shift(@final_settings);
chomp(@final_settings);
shift(@gulp_output);
chomp(@gulp_output);
shift(@defects_data);
shift(@persistent_data);
shift(@elastic_data);
shift(@atom_coords);
shift(@offset_vectors);
chomp (@offset_vectors);
push (@offset_vectors,"0.0 0.0 0.0");

if ($opti_defect ne '') {
  @volumes = (0);
  $gulp_keywords =~ s%conv%conp%g;
}

if ($opti_perfect ne '') {
  @volumes = @pressures = (0);
  $gulp_keywords =~ s%defe%%g;
  $gulp_keywords =~ s%conv%conp%g;
  @defects_data = "O INTE 0.0 0.0 0.0";
  if ($gulp_keywords !~ /prop/) {
    $gulp_keywords .= " prop";
    }
  $n_defect_master = 1;
}

if ($cluster_calcs ne '') {
  $n_defect_master = 1;
}




@cascade_regions =  split(/ +/,$size);
$reg_1 = $cascade_regions[1];
$reg_2 = $cascade_regions[2];
if (20 > ($reg_2 - $reg_1)) {
  $pot_cutoff = $reg_2 - $reg_1;
  print "WARNING: region IIa is smaller than the standard, 20 Å potential cutoff\n" ;
  } else {
  $pot_cutoff = $reg_2 - $reg_1 - 1;
  }

$init_settings = ();
foreach $line (@settings) {
	$init_settings .= $line."\n";
}
$max_shel_disp = 1 + 0.44;

foreach $line (@elastic_data) {
	@tmp = split(/ +/, $line);
	push @elastic_formatted, [ @tmp ];
}

$elastic_matrix = Math::MatrixReal->new_from_string(<<"MATRIX");
[ $elastic_formatted[0][0] $elastic_formatted[0][1] $elastic_formatted[0][2] $elastic_formatted[0][3] $elastic_formatted[0][4] $elastic_formatted[0][5] ]
[ $elastic_formatted[1][0] $elastic_formatted[1][1] $elastic_formatted[1][2] $elastic_formatted[1][3] $elastic_formatted[1][4] $elastic_formatted[1][5] ]
[ $elastic_formatted[2][0] $elastic_formatted[2][1] $elastic_formatted[2][2] $elastic_formatted[2][3] $elastic_formatted[2][4] $elastic_formatted[2][5] ]
[ $elastic_formatted[3][0] $elastic_formatted[3][1] $elastic_formatted[3][2] $elastic_formatted[3][3] $elastic_formatted[3][4] $elastic_formatted[3][5] ]
[ $elastic_formatted[4][0] $elastic_formatted[4][1] $elastic_formatted[4][2] $elastic_formatted[4][3] $elastic_formatted[4][4] $elastic_formatted[4][5] ]
[ $elastic_formatted[5][0] $elastic_formatted[5][1] $elastic_formatted[5][2] $elastic_formatted[5][3] $elastic_formatted[5][4] $elastic_formatted[5][5] ]
MATRIX
$elastic_inverse = $elastic_matrix->inverse;

%compliance_const = ();
for ($i=1;$i<=6;$i++) {
for ($j=1;$j<=6;$j++) {
$compliance_const{$i}{$j} = $elastic_inverse->element($i,$j);
}
}

$isothermal_compressibilty=$compliance_const{1}{1}+$compliance_const{1}{2}+$compliance_const{1}{3}+$compliance_const{2}{1}+$compliance_const{2}{2}+$compliance_const{2}{3}+$compliance_const{3}{1}+$compliance_const{3}{2}+$compliance_const{3}{3};
$a = $cell_data[0];
$b = $cell_data[1];
$c = $cell_data[2];
$alpha = $cell_data[3]/180*pi;
$beta = $cell_data[4]/180*pi;
$gamma = $cell_data[5]/180*pi;

$latt_const = $c;
$s = ($alpha+$beta+$gamma)/2;
$V= 2*$a*$b*$latt_const*sqrt(sin($s)*sin($s-$alpha)*sin($s-$beta)*sin($s-$gamma));
$a_star = $b*$latt_const*sin($alpha)/$V;
$latt_matrix_V0_11 = 1/($a_star*$latt_const);
$latt_matrix_V0_21 = $a*(cos($gamma)-cos($alpha)*cos($beta))/($latt_const*sin($alpha));
$latt_matrix_V0_31 = $a*cos($beta)/$latt_const;
$latt_matrix_V0_22 = $b*sin($alpha)/$latt_const;
$latt_matrix_V0_32 = $b*cos($alpha)/$latt_const;
$latt_matrix_V0_33 = 1;

# SUPERCELL loop, produces a supercell in a .frac file format.
if ($supercell_only eq 'supercell') {
  print " ## A 1x1x1 supercell is a bit pointless\n ## Please specify the supercell you want in multiples of a b and c\n";
  my @supercell = split(/ +/,<STDIN>);
  $a_multiple = $supercell[0];
  $b_multiple = $supercell[1];
  $c_multiple = $supercell[2];
  chomp($c_multiple);

print "  ##  A $a_multiple x $b_multiple x $c_multiple supercell will be made\n";
open (CELLOUT, ">$a_multiple$b_multiple$c_multiple.frac");

foreach $line (@atom_coords) {
		chomp($line);
		@info = split(/ +/,$line);
        $atom = $info[0];
        $core_shel = $info[1];
        $a_temp = $info[2];
        $b_temp = $info[3];
        $c_temp = $info[4];
        for($a_step=0; $a_step < $a_multiple; $a_step++) {
			$a_new = ($a_temp+$a_step)/$a_multiple;
			for($b_step=0 ;$b_step < $b_multiple; $b_step++) {
				$b_new = ($b_temp+$b_step)/$b_multiple;
				for($c_step=0; $c_step < $c_multiple; $c_step++) {
					$c_new = ($c_temp+$c_step)/$c_multiple;
                printf CELLOUT ("%s %s %.10f %.10f %.10f\n", $atom, $core_shel, $a_new, $b_new, $c_new);
                }
            }
        }
	}
print CELLOUT "space\n1\n";
close CELLOUT;
die;
}




#$max_shel_disp = sprintf("%.7f", ($max_shel_disp/$c));

$reg_1_V0 = sprintf("%.7f", ($reg_1/$c));
$reg_2_V0 = sprintf("%.7f", ($reg_2/$c));
$pot_cutoff_V0 = sprintf("%.7f", ($pot_cutoff/$c));
$max_shel_disp_V0 = sprintf("%.7f", ($max_shel_disp/$c));
$cascade_cell_input_V0 = "REGI RADI ".($reg_1_V0)." ".($reg_2_V0)." ".$c." ".($pot_cutoff_V0)." ".($max_shel_disp_V0)." 1.0 5.0 0.0 0.0\n";
$cascade_LATT_input_V0 = sprintf("LATT\n%.8f 0.00000000 0.00000000\n%.8f %.8f 0.00000000\n%.8f %.8f %.8f", $latt_matrix_V0_11, $latt_matrix_V0_21, $latt_matrix_V0_22, $latt_matrix_V0_31, $latt_matrix_V0_32, $latt_matrix_V0_33);
$gulp_cell_input_V0 = sprintf("cell\n%.7f %.7f %.7f %.7f %.7f %.7f",$cell_data[0], $cell_data[1], $cell_data[2], $cell_data[3], $cell_data[4], $cell_data[5]);



%defect_species=();
%defect_site=();
%defect_a=();
%defect_b=();
%defect_c=();
$n_defect =0;
@defect_temp = @defects_data;
foreach $line (@defect_temp) {
	chomp($line);
	@info = split(/ +/,$line);
	$defect_species{ $n_defect } = $info[0];
	$defect_site{ $n_defect } = $info[1];
	$defect_a{ $n_defect } = $info[2];
	$defect_b{ $n_defect } = $info[3];
	$defect_c{ $n_defect } = $info[4];
	$n_defect += 1;
}


%persistent_species=();
%persistent_site=();
%persistent_a=();
%persistent_b=();
%persistent_c=();
$n_persistent =0;
foreach $line (@persistent_data) {
         chomp($line);
         @info = split(/ +/,$line);
         $persistent_species{ $n_persistent } = $info[0];
         $persistent_site{ $n_persistent } = $info[1];
         $persistent_a{ $n_persistent } = $info[2];
         $persistent_b{ $n_persistent } = $info[3];
         $persistent_c{ $n_persistent } = $info[4];
         $n_persistent += 1;
}

foreach $atom (@atom_coords) {
	my @info = split(/ +/, $atom);
	$info[1] =~ s/CORE/core/g;
	$info[1] =~ s/SHEL/shel/g;
	$frac_atom_coords .= sprintf("%s %s %.11f %.11f %.11f\n", $info[0], $info[1], $info[2], $info[3], $info[4]);
}





# The volume adjustments start here,
$subjob_no = 0;
open (VOL, ">>cell_parameters_list.txt");
foreach $pressure (@pressures) {
foreach $vol (@volumes) {
$vol_change = $vol/100;
$pressure_input = "pressure ".$pressure."\n";
$principle_strain_a = $vol_change*($compliance_const{1}{1}+$compliance_const{2}{1}+$compliance_const{3}{1})/$isothermal_compressibilty;
$principle_strain_b = $vol_change*($compliance_const{1}{2}+$compliance_const{2}{2}+$compliance_const{3}{2})/$isothermal_compressibilty;
$principle_strain_c = $vol_change*($compliance_const{1}{3}+$compliance_const{2}{3}+$compliance_const{3}{3})/$isothermal_compressibilty;
$latt_matrix_new_11 = $latt_matrix_V0_11*($principle_strain_a+1);
$latt_matrix_new_21 = $latt_matrix_V0_21*($principle_strain_a+1);
$latt_matrix_new_31 = $latt_matrix_V0_31*($principle_strain_a+1);
$latt_matrix_new_22 = $latt_matrix_V0_22*($principle_strain_b+1);
$latt_matrix_new_32 = $latt_matrix_V0_32*($principle_strain_b+1);
$latt_matrix_new_33 = $latt_matrix_V0_33*($principle_strain_c+1);

$cascade_LATT_matrix = Math::MatrixReal->new_from_string(<<"LATT_MATRIX");
[ $latt_matrix_new_11 0.00 0.00 ]
[ $latt_matrix_new_21 $latt_matrix_new_22 0.00 ]
[ $latt_matrix_new_31 $latt_matrix_new_32 $latt_matrix_new_33 ]
LATT_MATRIX


$vol =~ s/\./x/g;
$vol =~ s/-/m/g;
$reg_1_new = (($reg_1**3)*(1+$vol_change))**(1/3)/$c;
$reg_2_new = (($reg_2**3)*(1+$vol_change))**(1/3)/$c;
$pot_cutoff_new = (($pot_cutoff**3)*(1+$vol_change))**(1/3)/$c;

$cascade_cell_input = sprintf("REGI RADI %.8f %.8f %.8f %.8f %.8f 1.0 5.0 0.0 0.0",$reg_1_new, $reg_2_new, $latt_const, $pot_cutoff_new, $max_shel_disp_V0);
$cascade_LATT_input = sprintf("\nLATT\n%.8f 0.00000000 0.00000000\n%.8f %.8f 0.00000000\n%.8f %.8f %.8f", $latt_matrix_new_11, $latt_matrix_new_21, $latt_matrix_new_22, $latt_matrix_new_31, $latt_matrix_new_32, $latt_matrix_new_33);


$X_vect = $cascade_LATT_matrix->column(1);
$Y_vect = $cascade_LATT_matrix->column(2);
$Z_vect = $cascade_LATT_matrix->column(3);
$a_gulp_new = $X_vect->length()*$c;
$b_gulp_new = $Y_vect->length()*$c;
$c_gulp_new = $Z_vect->length()*$c;
$alpha_gulp_new = acos($Z_vect->scalar_product($Y_vect)/($Z_vect->length())/($Y_vect->length()))*180/pi;
$beta_gulp_new = acos($X_vect->scalar_product($Z_vect)/($X_vect->length())/($Z_vect->length()))*180/pi;
$gamma_gulp_new = acos($X_vect->scalar_product($Y_vect)/($X_vect->length())/($Y_vect->length()))*180/pi;
$gulp_cell_input = sprintf("cell\n%.7f %.7f %.7f %.7f %.7f %.7f",$a_gulp_new, $b_gulp_new, $c_gulp_new, $alpha_gulp_new, $beta_gulp_new, $gamma_gulp_new);
printf VOL ("dVol %.5f%s cell %.7f %.7f %.7f %.7f %.7f %.7f\n",($vol_change*100) ,"%" , $a_gulp_new, $b_gulp_new, $c_gulp_new, $alpha_gulp_new, $beta_gulp_new, $gamma_gulp_new);
#####

#Atom coords in XYZ
$XYZ_atom_coords = ();
foreach $line (@atom_coords) {
	$XYZ_atom_coords .= &XYZ_coord_norm($line,$cascade_LATT_matrix);
}

#persistent output in XYZ
$persistent_output = "";
for($count = 0; $count < $n_persistent; $count++) {
$persistent_XYZ=&convert_fractional($persistent_a{$count}, $persistent_b{$count}, $persistent_c{$count}, $cascade_LATT_matrix);

	if (($persistent_site{$count} =~ /INTE/) && ($persistent_species{$count} !~ /VACA/)) {
		$persistent_output.=sprintf ("$persistent_species{$count} CORE INTE %.15f %.15f %.15f\n",$persistent_XYZ->element(1,1), $persistent_XYZ->element(2,1), $persistent_XYZ->element(3,1));
		$persistent_output_gulp.=sprintf("interstitial $persistent_species{$count} core %.7f %.7f %.7f\n",$persistent_a{$count}, $persistent_b{$count}, $persistent_c{$count});
		foreach $shel_ion (@shel_ions) {if ($persistent_species{$count} =~ /$shel_ion/) {
			$persistent_output.=sprintf ("$persistent_species{$count} SHEL INTE %.15f %.15f %.15f\n",$persistent_XYZ->element(1,1), $persistent_XYZ->element(2,1), $persistent_XYZ->element(3,1));
			$persistent_output_gulp.=sprintf("interstitial $persistent_species{$count} shel %.7f %.7f %.7f\n",$persistent_a{$count}, $persistent_b{$count}, $persistent_c{$count});
				}
			}
	}

	if (($persistent_site{$count} !~ /INTE/) && ($persistent_species{$count} !~ /VACA/)) {
	$persistent_output.=sprintf ("$persistent_site{$count} CORE VACA %.15f %.15f %.15f\n",$persistent_XYZ->element(1,1), $persistent_XYZ->element(2,1), $persistent_XYZ->element(3,1));
	$persistent_output_gulp.=sprintf("vacancy $persistent_site{$count} core %.7f %.7f %.7f\n",$persistent_a{$count}, $persistent_b{$count}, $persistent_c{$count});
		foreach $shel_ion (@shel_ions) {if ($persistent_species{$count} =~ /$shel_ion/) {
			$persistent_output.=sprintf ("$persistent_site{$count} SHEL VACA %.15f %.15f %.15f\n",$persistent_XYZ->element(1,1), $persistent_XYZ->element(2,1), $persistent_XYZ->element(3,1));
			$persistent_output_gulp.=sprintf("vacancy $persistent_site{$count} shel %.7f %.7f %.7f\n",$persistent_a{$count}, $persistent_b{$count}, $persistent_c{$count});
		}}
	$persistent_output.=sprintf ("$persistent_species{$count} CORE INTE %.15f %.15f %.15f\n",$persistent_XYZ->element(1,1), $persistent_XYZ->element(2,1), $persistent_XYZ->element(3,1));
	$persistent_output_gulp.=sprintf("interstitial $persistent_species{$count} core %.7f %.7f %.7f\n",$persistent_a{$count}, $persistent_b{$count}, $persistent_c{$count});
		foreach $shel_ion (@shel_ions) {if ($persistent_species{$count} =~ /$shel_ion/) {
			$persistent_output.=sprintf ("$persistent_species{$count} SHEL INTE %.15f %.15f %.15f\n",$persistent_XYZ->element(1,1), $persistent_XYZ->element(2,1), $persistent_XYZ->element(3,1));
			$persistent_output_gulp.=sprintf("interstitial $persistent_species{$count} shel %.7f %.7f %.7f\n",$persistent_a{$count}, $persistent_b{$count}, $persistent_c{$count});
		}}
	}
	if (($persistent_site{$count} !~ /INTE/) && ($persistent_species{$count} =~ /VACA/)) {
	$persistent_output.=sprintf ("$persistent_site{$count} CORE VACA %.15f %.15f %.15f\n",$persistent_XYZ->element(1,1), $persistent_XYZ->element(2,1), $persistent_XYZ->element(3,1));
	$persistent_output_gulp.=sprintf("vacancy $persistent_site{$count} core %.7f %.7f %.7f\n",$persistent_a{$count}, $persistent_b{$count}, $persistent_c{$count});
		foreach $shel_ion (@shel_ions) {if ($persistent_species{$count} =~ /$shel_ion/) {
			$persistent_output.=sprintf ("$persistent_site{$count} SHEL VACA %.15f %.15f %.15f\n",$persistent_XYZ->element(1,1), $persistent_XYZ->element(2,1), $persistent_XYZ->element(3,1));
			$persistent_output_gulp.=sprintf("vacancy $persistent_site{$count} shel %.7f %.7f %.7f\n",$persistent_a{$count}, $persistent_b{$count}, $persistent_c{$count});
		}}
	}
}



#
#---- The rest of the script writes the files.
#
if ($n_defect_master ne '') {
$n_defect = $n_defect_master;
}
for($count = 0; $count < $n_defect; $count++) {

##### BOND OFFSETTING ######
if ($bond_offset > -0.1) {
@offset_vectors = ("0 0 0");
	#Get defect coords
	$defect = $defects_data[$count];
	chomp($defect);
	@info = split(/ +/,$defect);
	$defect_XYZ_a = $info[2]*$latt_matrix_new_11*$latt_const;
	$defect_XYZ_b = $info[3]*$latt_matrix_new_22*$latt_const;
	$defect_XYZ_c = $info[4]*$latt_matrix_new_33*$latt_const;
	$origin = Math::MatrixReal->new_from_cols([[$defect_XYZ_a, $defect_XYZ_b, $defect_XYZ_c]]);
	$translation_vect = $origin->shadow();

	#make a 3x3x3 supercell -1 -> +2 in a b c
SUPER:	foreach $line (@atom_coords) {
		chomp($line);
		@info = split(/ +/,$line);
        $atom = $info[0];
		#ignore irrelevent ions and shel species
		next SUPER if ($atom !~ /$bond_offset_species/);
        $core_shel = $info[1];
		next SUPER if ($core_shel =~ / s /);
		next SUPER if ($core_shel =~ /shel/);
		next SUPER if ($core_shel =~ /SHEL/);
        $a_temp = $info[2];
        $b_temp = $info[3];
        $c_temp = $info[4];
        for($a_step=-1; $a_step <= 2; $a_step++) {
			$a_new = $a_temp+$a_step;
			for($b_step=-1 ;$b_step <= 2; $b_step++) {
				$b_new = $b_temp+$b_step;
				for($c_step=-1; $c_step <= 2; $c_step++) {
					$c_new = $c_temp+$c_step;
                $coord = sprintf("%s %s %.7f %.7f %.7f", $atom, $core_shel, $a_new, $b_new, $c_new);
				push (@supercell, $coord);
#                print $coord."\n";
				}
            }
        }
	}
	foreach $line (@supercell) {
		@info = split(/ +/,$line);
            $a_super = $info[2]*$latt_matrix_new_11*$latt_const;
            $b_super = $info[3]*$latt_matrix_new_22*$latt_const;
            $c_super = 0.00001+($info[4]*$latt_matrix_new_33*$latt_const);
            my $atom_vect = Math::MatrixReal->new_from_cols( [[$a_super, $b_super, $c_super]]);
            $translation_vect -> subtract($atom_vect,$origin);
            $length = $translation_vect->length();
			$length = $length*0.9999999999999999;
            $scaling_coeff = (($length-$bond_offset)/$length);
            $translation_vect -> multiply_scalar($translation_vect,$scaling_coeff);
            $a_super = $translation_vect->element(1,1);
            $b_super = $translation_vect->element(2,1);
            $c_super = $translation_vect->element(3,1);
            $a_super = $a_super/$latt_matrix_new_11/$latt_const;
            $b_super = $b_super/$latt_matrix_new_22/$latt_const;
            $c_super = $c_super/$latt_matrix_new_33/$latt_const;
            $coord = sprintf("%.6f %.6f %.6f", $a_super, $b_super, $c_super);
            $offset_input_line{$length} = $line;
            $offset_list{$length} = $coord;
			push (@length_list, $length);
	}

	$n = 0;
	my @unique_length_list = ();
    my %Seen   = ();
	foreach my $elem ( @length_list )
      {
      next if $Seen{ $elem }++;
      push @unique_length_list, $elem;
      }
	  @unique_length_list = sort { $a <=> $b } @unique_length_list;
	until($n>=13) {
#		print $offset_input_line{$unique_length_list[$n]}." x ".$offset_list{$unique_length_list[$n]}." $unique_length_list[$n]\n";
		push (@offset_vectors, $offset_list{$unique_length_list[$n]});
		$n++;
	}
}

      foreach $offset_vect (@offset_vectors) {
        @offset = split(/ +/,$offset_vect);
        $defect_origXYZ=&convert_fractional($defect_a{$count}, $defect_b{$count}, $defect_c{$count}, $cascade_LATT_matrix);
        $defect_XYZ=&convert_fractional($offset[0]+$defect_a{$count}, $offset[1]+$defect_b{$count}, $offset[2]+$defect_c{$count}, $cascade_LATT_matrix);
        $offset_vect_length=sqrt($offset[0]**2+$offset[1]**2+$offset[2]**2);
        if ($offset_vect_length==0) {
          $offset_label="";
        } else {
          $offset_label=sprintf("+%.5f,%.5f,%.5f",$offset[0],$offset[1],$offset[2]);
        }
$defect_aXYZ = $defect_XYZ->element(1,1);
$defect_bXYZ = $defect_XYZ->element(2,1);
$defect_cXYZ = $defect_XYZ->element(3,1);

$defect_afrac = $offset[0]+$defect_a{$count};
$defect_bfrac = $offset[1]+$defect_b{$count};
$defect_cfrac = $offset[2]+$defect_c{$count};


$subjob = $subjob_no."_grid_defect";

$vol_label = $vol;
$vol_label =~ s/\./x/g;
$vol_label =~ s/-/m/g;
$pressure_label = $pressure;
$pressure_label =~ s/\./x/g;
$pressure_label =~ s/-/m/g;
#_________________________________________________________________________________________________________________
##  DEFECT CLUSTERS IN GULP
if ($cluster_calcs ne '') {
#@Grp4_ions = qw(Ti);
@Grp4_ions = qw(Ce Hf Zr Ti);
$cluster_file = $cluster_calcs;
open (CLUSTER_DATA, "<$cluster_file") or die "cluster data not found,\ntype the name of the data file after the cluster_calcs option\n";
@cluster_data = <CLUSTER_DATA>;
close CLUSTER_DATA;
$cluster_n = -1;
foreach $Group4_ion (@Grp4_ions) {    ####### <- changes the Grp4 string into Ce, Hf, Zr and Ti  !!!!!!!!!!!!4 LINES TO BE REMOVED!!!!!!!!
foreach $cluster_data (@cluster_data) {
$cluster_n++;
$clus_title = $cluster_data;
$clus_title =~ s/-TITLE_END DEFE.*//g;
$clus_title =~ s/.*TITLE_START //g;
$clus_title =~ s/Grp4/$Group4_ion/g;  ####### <- changes the Grp4 string into Ce, Hf, Zr and Ti  !!!!!!!!!!!!4 LINES TO BE REMOVED!!!!!!!!
chomp($clus_title);
$cluster = $cluster_data;
$cluster =~ s/.*DEFE//g;
$cluster =~ s/CLUSTER_END//g;
$cluster =~ s/Grp4/$Group4_ion/g;     ####### <- changes the Grp4 string into Ce, Hf, Zr and Ti  !!!!!!!!!!!!4 LINES TO BE REMOVED!!!!!!!!

@cluster = split(/\\n/, $cluster);
$file = sprintf("cluster-$sim_title\@-$clus_title\-dVol-%s-dP-%s", $vol_label, $pressure_label);
$subjob = $cluster_n."_cluster_defect";
open (OUT, ">$subjob".".glp");
print OUT "$gulp_keywords\ntitle\n$file\nend\n";
print OUT "$gulp_cell_input\nfractional\n$frac_atom_coords"."$space"."$pressure_input"."$size";
    foreach $line (@cluster) {
	print OUT "$line\n";
#______________________________________________________________________________________
	#########  THESE LINES REFORMAT THE OLD VERSIONS OF THE CLUSTER SCRIPT OUTPUT
#	@defect_cluster = split(/\\n/,$line);
#	foreach $defect (@defect_cluster) {
#	@info = split(/ +/,$defect);
#	    if ($info[2] =~ /VACA/) {
#            print OUT "vaca $info[0] $info[1] $info[3] $info[4] $info[5]\n";  # <-- Specifies defe type, element and coords
#	}   elsif ($info[2] =~ /INTE/) {
#            print OUT "inte $info[0] $info[1] $info[3] $info[4] $info[5]\n";  # <-- Specifies defe type, element and coords
#        }   elsif ((defined($info[4])) && (($info[2] !~ /VACA/) or ($info[2] !~ /INTE/))) {
#            print OUT "impurity $info[2] $info[3] $info[4] $info[5]\n";  # <-- Specifies defe type, element and coords
#        }
#    }
#=======================================================================================
	}
	foreach $line (@gulp_potentials) {
		print OUT "$line\n";
	}
	foreach $line (@gulp_output) {
		print OUT "$line\n";
	}
	close OUT;

}
}                                       ####### <- changes the Grp4 string into Ce, Hf, Zr and Ti  !!!!!!!!!!!!4 LINES TO BE REMOVED!!!!!!!!

}
#_________END DEFECT CLUSTERS IN GULP________________________________________________________________________________________________________





$file = sprintf("%s-%s-$sim_title\@%.5f,%.5f,%.5f%s-dVol-%s-dP-%s", $defect_species{$count}, $defect_site{$count}, $defect_a{$count}, $defect_b{$count}, $defect_c{$count}, $offset_label, $vol_label, $pressure_label);
# INTERSTITIALS CASCADE
if ($defect_site{$count} =~ /INTE/) {
  $subjob_no ++;
        if ($IS_CASCADE == 1) {
	open (OUT, ">$subjob".".cas");
	print OUT "TITLE\n".$file."\nENDS\n$init_settings";
	print OUT $cascade_cell_input.$cascade_LATT_input."\nBASI\n";
	print OUT "$XYZ_atom_coords";
	printf OUT ("CENTRE %.15f %.15f %.15f\nENDS\n",$defect_aXYZ, $defect_bXYZ, $defect_cXYZ);
	print OUT "DEFE\n$persistent_output";
	printf OUT ("$defect_species{$count} CORE INTE %.15f %.15f %.15f\n",$defect_aXYZ, $defect_bXYZ, $defect_cXYZ);
	foreach $shel_ion (@shel_ions) {
		if ($defect_species{$count} =~ /$shel_ion/) {
			printf OUT ("$defect_species{$count} SHEL INTE %.15f %.15f %.15f\n",$defect_aXYZ, $defect_bXYZ, $defect_cXYZ);
		}
	}
	print OUT "ENDS\n";
	foreach $line (@potentials) {
		print OUT "$line\n";
	}
	foreach $line (@final_settings) {
		print OUT "$line\n";
	}
	close OUT;
	}

# INTERSTITIALS GULP
	if ($IS_GULP == 1) {
	open (OUT, ">$subjob".".glp");
	print OUT "$gulp_keywords\ntitle\n$file\nend\n";
	print OUT "$gulp_cell_input\nfractional\n$frac_atom_coords"."$space"."$pressure_input";
	printf OUT ("%scentre %.7f %.7f %.7f\n",$size, $defect_afrac, $defect_bfrac, $defect_cfrac);
	print OUT "$persistent_output";
	printf OUT ("interstitial $defect_species{$count} core %.7f %.7f %.7f\n",$defect_afrac, $defect_bfrac, $defect_cfrac);
	foreach $shel_ion (@shel_ions) {
		if ($defect_species{$count} =~ /$shel_ion/) {
			printf OUT ("interstitial $defect_species{$count} shel %.7f %.7f %.7f\n",$defect_afrac, $defect_bfrac, $defect_cfrac);
		}
	}
	foreach $line (@gulp_potentials) {
		print OUT "$line\n";
	}
	foreach $line (@gulp_output) {
		print OUT "$line\n";
	}
	close OUT;
        }
}


# SUBSTITUTIONS CASCADE
if (($defect_site{$count} !~ /INTE/) && ($defect_species{$count} !~ /VACA/)) {
$subjob_no ++;
#$file = sprintf("%s-%s-$sim_title\@%.5f,%.5f,%.5f%s-dVol-%s", $defect_species{$count}, $defect_site{$count}, $defect_a{$count}, $defect_b{$count}, $defect_c{$count}, $offset_label, $vol);
	if ($IS_CASCADE == 1) {
	open (OUT, ">$subjob".".cas");
	print OUT "TITLE\n$file\nENDS\n$init_settings";
	print OUT $cascade_cell_input.$cascade_LATT_input."\nBASI\n";
	print OUT "$XYZ_atom_coords";
	printf OUT ("CENTRE %.15f %.15f %.15f\nENDS\n",$defect_aXYZ, $defect_bXYZ, $defect_cXYZ);
	print OUT "DEFE\n$persistent_output";
	printf OUT ("$defect_site{$count} CORE VACA %.15f %.15f %.15f\n",$defect_origXYZ->element(1,1), $defect_origXYZ->element(2,1), $defect_origXYZ->element(3,1));
	foreach $shel_ion (@shel_ions) {
		if ($defect_site{$count} =~ /$shel_ion/) {
			printf OUT ("$defect_site{$count} SHEL VACA %.15f %.15f %.15f\n",$defect_origXYZ->element(1,1), $defect_origXYZ->element(2,1), $defect_origXYZ->element(3,1));
		}
	}
	printf OUT ("$defect_species{$count} CORE INTE %.15f %.15f %.15f\n",$defect_aXYZ, $defect_bXYZ, $defect_cXYZ);
	foreach $shel_ion (@shel_ions) {
		if ($defect_species{$count} =~ /$shel_ion/) {
			printf OUT ("$defect_species{$count} SHEL INTE %.15f %.15f %.15f\n",$defect_aXYZ, $defect_bXYZ, $defect_cXYZ);
		}
	}
	print OUT "ENDS\n";
	foreach $line (@potentials) {
			print OUT "$line\n";
	}
	foreach $line (@final_settings) {
			print OUT "$line\n";
	}
	close OUT;
	}

# SUBSTITUTIONS GULP
	if ($IS_GULP == 1) {
	open (OUT, ">$subjob".".glp");
	print OUT "$gulp_keywords\ntitle\n$file\nend\n";
	print OUT "$gulp_cell_input\nfractional\n$frac_atom_coords"."$space"."$pressure_input";
	printf OUT ("%scentre %.7f %.7f %.7f\n",$size, $defect_afrac, $defect_bfrac, $defect_cfrac);
	print OUT "$persistent_output";
	printf OUT ("vaca   %.7f %.7f %.7f\n",$defect_a{$count}, $defect_b{$count}, $defect_c{$count});
#	printf OUT ("vaca $defect_site{$count}  %.7f %.7f %.7f\n",$defect_a{$count}, $defect_b{$count}, $defect_c{$count});
	foreach $shel_ion (@shel_ions) {
		if ($defect_site{$count} =~ /$shel_ion/) {
			printf OUT ("vaca   %.7f %.7f %.7f\n",$defect_a{$count}, $defect_b{$count}, $defect_c{$count});
#			printf OUT ("vaca $defect_site{$count}  %.7f %.7f %.7f\n",$defect_a{$count}, $defect_b{$count}, $defect_c{$count});
		}
	}
	printf OUT ("interstitial $defect_species{$count} core %.7f %.7f %.7f\n",$defect_afrac, $defect_bfrac, $defect_cfrac);
	foreach $shel_ion (@shel_ions) {
		if ($defect_species{$count} =~ /$shel_ion/) {
			printf OUT ("interstitial $defect_species{$count} shel %.7f %.7f %.7f\n",$defect_afrac, $defect_bfrac, $defect_cfrac);
		}
	}
	foreach $line (@gulp_potentials) {
		print OUT "$line\n";
	}
	foreach $line (@gulp_output) {
		print OUT "$line\n";
	}
	close OUT;
	}
}

# VACANCIES CASCADE
if ($defect_species{$count} =~ /VACA/) {
$subjob_no ++;
#$file = sprintf("%s-%s-$sim_title\@%.5f,%.5f,%.5f%s-dVol-%s", $defect_species{$count}, $defect_site{$count}, $defect_a{$count}, $defect_b{$count}, $defect_c{$count}, $offset_label, $vol);
	if ($IS_CASCADE == 1) {
	open (OUT, ">$subjob".".cas");
	print OUT "TITLE\n$file\nENDS\n$init_settings";
	print OUT $cascade_cell_input.$cascade_LATT_input."\nBASI\n";
	print OUT "$XYZ_atom_coords";
	printf OUT ("CENTRE %.15f %.15f %.15f\nENDS\n",$defect_aXYZ, $defect_bXYZ, $defect_cXYZ);
	print OUT "DEFE\n$persistent_output";
	printf OUT ("$defect_site{$count} CORE VACA %.15f %.15f %.15f\n",$defect_origXYZ->element(1,1), $defect_origXYZ->element(2,1), $defect_origXYZ->element(3,1));
	foreach $shel_ion (@shel_ions) {
		if ($defect_site{$count} =~ /$shel_ion/) {
			printf OUT ("$defect_site{$count} SHEL VACA %.15f %.15f %.15f\n",$defect_origXYZ->element(1,1), $defect_origXYZ->element(2,1), $defect_origXYZ->element(3,1));
		}
	}
	print OUT "ENDS\n";
	foreach $line (@potentials) {
		print OUT "$line\n";
	}
	foreach $line (@final_settings) {
		print OUT "$line\n";
	}
	close OUT;
	}

# VACANCIES GULP
	if ($IS_GULP == 1) {
	open (OUT, ">$subjob".".glp");
	print OUT "$gulp_keywords\ntitle\n$file\nend\n";
	print OUT "$gulp_cell_input\nfractional\n$frac_atom_coords"."$space"."$pressure_input";
	printf OUT ("%scentre %.7f %.7f %.7f\n",$size, $defect_a{$count}, $defect_b{$count}, $defect_c{$count});
	print OUT "$persistent_output";
	printf OUT ("vaca  %.7f %.7f %.7f\n",$defect_a{$count}, $defect_b{$count}, $defect_c{$count});
#	printf OUT ("vaca $defect_site{$count}  %.7f %.7f %.7f\n",$defect_a{$count}, $defect_b{$count}, $defect_c{$count});
#	foreach $shel_ion (@shel_ions) {
#		if ($defect_species{$count} =~ /$shel_ion/) {
#			printf OUT ("vaca $defect_site{$count}  %.7f %.7f %.7f\n",$defect_a{$count}, $defect_b{$count}, $defect_c{$count});
#		}
#	}
	foreach $line (@gulp_potentials) {
		print OUT "$line\n";
	}
	foreach $line (@gulp_output) {
		print OUT "$line\n";
	}
	close OUT;
	}
}

}
}
}
}
close VOL;
