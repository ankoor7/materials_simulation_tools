#! /usr/bin/perl -w
#Author: Ankoor Patel
#Date: 7/12/09
#Purpose: Extracts results from vasp results

BEGIN {
push @INC,"/home/ap1702/lib/perl5";
}


use Cwd;
use File::Find;
use Math::MatrixReal;
use POSIX qw/strftime/;
use Term::ANSIColor qw(:constants);

$date_stamp =  strftime('%Y-%m-%d_%H-%M%p',localtime); ## outputs 17-Dec-2008 10:08se POSIX qw/strftime/;

$output_results = "results_vasp-".$date_stamp.".txt";
open(OUT_RESULTS, ">>$output_results");


####### SUBROUTINES ######
#########################################################################################################################

## COORD CONVERSION ##
sub convert_fractional {
	return $_[3]->multiply(Math::MatrixReal->new_from_cols([[$_[0], $_[1], $_[2]]]));
}

sub convert_cartesian {
    $inverse = $_[3]->inverse;
	return $inverse->multiply(Math::MatrixReal->new_from_cols([[$_[0], $_[1], $_[2]]]));
}

####### END SUBROUTINES
#########################################################################################################################
#########################################################################################################################

# This searches through all directories and runs the subroutine &edits on each file
@ARGV = ('.') unless @ARGV;
push(@ARGV, '.');
$dir = shift @ARGV;
find(\&edits, $dir);
close OUT_RESULTS;

system("cp $output_results ~/freshly_squeezed/");
if ( $? == -1 ) {
    print "\n\nfinal copy command failed: $!\n\n";
} elsif ( $? == 0 ) {
    @quotes = ('You wake up at Seatac, SFO, LAX. You wake up at O\'Hare, Dallas-Fort Worth, BWI. Pacific, mountain, central. Lose an hour, gain an hour. This is your life, and it\'s ending one minute at a time. You wake up at Air Harbor International. If you wake up at a different time, in a different place, could you wake up as a different person?', 'This is your life and it\'s ending one minute at a time.', 'Fuck off with your sofa units and strine green stripe patterns, I say never be complete, I say stop being perfect, I say let... lets evolve, let the chips fall where they may.', 'Fight Club was the beginning, now it\'s moved out of the basement, it\'s called Project Mayhem.', 'Only after disaster can we be resurrected.', 'Now, a question of etiquette - as I pass, do I give you the ass or the crotch?', 'Tomorrow will be the most beautiful day of Raymond K. Hessel\'s life. His breakfast will taste better than any meal you and I have ever tasted.', 'Hey, you created me. I didn\'t create some loser alter-ego to make myself feel better. Take some responsibility!', 'People do it everyday, they talk to themselves... they see themselves as they\'d like to be, they don\'t have the courage you have, to just run with it.', 'All right, if the applicant is young, tell him he\'s too young. Old, too old. Fat, too fat. If the applicant then waits for three days without food, shelter, or encouragement he may then enter and begin his training.', 'I\'ve got a stomachful of Xanax. I took what was left of a bottle. It might have been too much.', 'Your whacked out bald freaks hit me with a fucking broom! They almost broke my arm! They were burning their fingertips with lye, the stink was unbelievable!', 'It\'s getting exciting now, two and one-half. Think of everything we\'ve accomplished, man. Out these windows, we will view the collapse of financial history. One step closer to economic equilibrium.', 'My God. I haven\'t been fucked like that since grade school.', 'I am Jack\'s smirking revenge.', 'Tyler Durden: Man, I see in fight club the strongest and smartest men who\'ve ever lived. I see all this potential, and I see squandering. God damn it, an entire generation pumping gas, waiting tables; slaves with white collars. Advertising has us chasing cars and clothes, working jobs we hate so we can buy shit we don\'t need. We\'re the middle children of history, man. No purpose or place. We have no Great War. No Great Depression. Our Great War\'s a spiritual war... our Great Depression is our lives. We\'ve all been raised on television to believe that one day we\'d all be millionaires, and movie gods, and rock stars. But we won\'t. And we\'re slowly learning that fact. And we\'re very, very pissed off.', 'First person that comes out this fucking door gets a... gets a *lead salad*, you understand?', 'All the ways you wish you could be, that\'s me. I look like you wanna look, I fuck like you wanna fuck, I am smart, capable, and most importantly, I am free in all the ways that you are not.', 'It\'s only after we\'ve lost everything that we\'re free to do anything.', 'What\'s that smell?', 'Is that your blood?', 'Some of it, yeah.', 'In the world I see - you are stalking elk through the damp canyon forests around the ruins of Rockefeller Center. You\'ll wear leather clothes that will last you the rest of your life. You\'ll climb the wrist-thick kudzu vines that wrap the Sears Tower. And when you look down, you\'ll see tiny figures pounding corn, laying strips of venison on the empty car pool lane of some abandoned superhighway.', 'I felt like destroying something beautiful.', 'You\'re not your job. You\'re not how much money you have in the bank. You\'re not the car you drive. You\'re not the contents of your wallet. You\'re not your fucking khakis. You\'re the all-singing, all-dancing crap of the world.', 'When you have insomnia, you\'re never really asleep... and you\'re never really awake.', 'Listen up, maggots. You are not special. You are not a beautiful or unique snowflake. You\'re the same decaying organic matter as everything else.', 'On a long enough timeline, the survival rate for everyone drops to zero.', 'Welcome to Fight Club. The first rule of Fight Club is: you do not talk about Fight Club. The second rule of Fight Club is: you DO NOT talk about Fight Club! Third rule of Fight Club: if someone yells "stop!", goes limp, or taps out, the fight is over. Fourth rule: only two guys to a fight. Fifth rule: one fight at a time, fellas. Sixth rule: the fights are bare knuckle. No shirt, no shoes, no weapons. Seventh rule: fights will go on as long as they have to. And the eighth and final rule: if this is your first time at Fight Club, you have to fight.', 'Tyler sold his soap to department stores at $20 a bar. Lord knows what they charged. It was beautiful. We were selling rich women their own fat asses back to them.', 'When people think you\'re dying, they really, really listen to you, instead of just... - instead of just waiting for their turn to speak?', 'The things you own end up owning you.', 'God Damn! We just had a near-life experience, fellas.', 'You have a kind of sick desperation in your laugh.', 'Sticking feathers up your butt does not make you a chicken.', 'I am Jack\'s cold sweat.', 'You\'re not getting this back. I consider it asshole tax.', 'I am Jack\'s raging bile duct.', 'A guy who came to Fight Club for the first time, his ass was a wad of cookie dough. After a few weeks, he was carved out of wood.', 'I ran. I ran until my muscles burned and my veins pumped battery acid. Then I ran some more.', 'After fighting, everything else in your life got the volume turned down.', 'If you wake up at a different time in a different place, could you wake up as a different person?', 'Without pain, without sacrifice, we would have nothing. Like the first monkey shot into space.', 'And then, something happened. I let go. Lost in oblivion. Dark and silent and complete. I found freedom. Losing all hope was freedom', 'I felt like putting a bullet between the eyes of every Panda that wouldn\'t screw to save its species. I wanted to open the dump valves on oil tankers and smother all the French beaches I\'d never see. I wanted to breathe smoke.', 'Everywhere I travel, tiny life. Single-serving sugar, single-serving cream, single pat of butter. The microwave Cordon Bleu hobby kit. Shampoo-conditioner combos, sample-packaged mouthwash, tiny bars of soap. The people I meet on each flight? They\'re single-serving friends', 'I am Jack\'s complete lack of surprise.', 'I am Jack\'s wasted life.', 'I am Jack\'s inflamed sense of rejection.', 'Fuck what you know. You need to forget about what you know, that\'s your problem. Forget about what you think you know about life, about friendship, and especially about you and me.', 'Life insurance pays off triple if you die on a business trip.', 'You had to give it to him: he had a plan. And it started to make sense, in a Tyler sort of way. No fear. No distractions. The ability to let that which does not matter truly slide.', 'I flipped through catalogs and wondered: What kind of dining set defines me as a person?', 'I\'ll bring us through this. As always. I\'ll carry you - kicking and screaming - and in the end you\'ll thank me.', 'We have just lost cabin pressure.', 'No, you\'re insane.', 'We are all part of the same compost heap.', 'Tyler\'s not here. Tyler went away. Tyler\'s gone.', 'Something on your mind, dear?', 'Don\'t worry. It\'s all taken care of, sir.', 'Alright, alright, I got it. I got it - shit I lost it.');
    my $random_number = int(rand(@quotes));
    print "\n".$quotes[$random_number]."\n";
    print "\n\nP.S.  I copied $output_results to ~/freshly_squeezed/ \n\n Goodbye, :)\n\n"
} else {
    printf "\n\nfinal copy command exited with value %d\n\n", $? >> 8;
}


#subroutine &edit
sub edits() {

#if file is OUTCAR do this
if ( -f and /OUTCAR?/ ) {
$selected_file = $_;


my $cwd = getcwd;
print BOLD, MAGENTA, "\n$cwd\n", RESET;

# these lines reset all variables used for data collection
$intro = '';
$result = $time = $vol_fin = $cutoff = $free_E = $n_kpoints = 'xxxxxxxx';
$external_pressure = $Pulay_stress = $result_displacements = 'xxxxxxxx';
@U_affects = @U_code = @U_values = @J_values = @outcar = @latt_vectors = @potentials = @lines = @new_coords = @orig_coords = @disp_element = @final_charges = ();
$a_fin = $b_fin = $c_fin = $KineticE_error_per_atom_n_atom = $s_charge = $p_charge = $d_charge = $f_charge = $s_charge_sum = $p_charge_sum = $d_charge_sum = $f_charge_sum = 0;
$finished = 1;

# Check if a viable CONTCAR has been written, i.e. if the file is larger than 0bytes
#$CONTCARsize = -s "$cwd/CONTCAR";
#if ($CONTCARsize == 0) {
#    $finished = 0;
#    print "NO VIABLE CONTCAR produced\n";
#}

# opens OUTCAR and reads potentials, atom energies and number of kpoints
open(OUTCAR_HANDLE, "<$cwd/$selected_file") or print "failed to open OUTCAR to read potentials\n";

if ($finished == 0) {
$print_next_line = 0;
MINIMISATION_LOOP:while (<OUTCAR_HANDLE>) {
        if ($print_next_line == 1) {
        print $_;
        $print_next_line = 0;
        }
        if (/energy without entropy =/) {
            print $_;
        } elsif (/length of vectors/) {
        $print_next_line = 1;
        print $_;
        }
    }
} else {
POTENTIALS_LOOP: while (<OUTCAR_HANDLE>) {
	if (/POTCAR:\s+(.*)\s+$/) {
	$pot = $1;
	$pot =~ s%\s+$%%g;
	$pot =~ tr% %_%;
	push (@potentials, "$pot");
	} elsif(/kinetic energy error for atom=\s+([-\d\.]+)/){
	$KineticE_error_per_atom_value = $1;
	$KineticE_error_per_atom_n_atom ++;
	$intro .= " E_error_per_atom Atom".$KineticE_error_per_atom_n_atom." ".$KineticE_error_per_atom_value." ";
	} elsif (/k-points\s+NKPTS =\s+([-\d\.]+)\s+/){
	$n_kpoints = $1;
	} elsif (/angular momentum for each species LDAUL =\s+([-\d\.]+.*[-\d\.]+)/){
	$U_affect_list = $1;
	@U_code = split(/ +/, $U_affect_list);
		foreach $value (@U_code) {
			if ($value == -1) {
			push (@U_affects, "none");
			} elsif ($value == 1) {
			push (@U_affects, "p");
			} elsif ($value == 2) {
			push (@U_affects, "d");
			} elsif ($value == 3) {
			push (@U_affects, "f");
			}

		}
	} elsif (/U\s\(eV\)\s+.*LDAUU =\s+([-\d\.]+.*[-\d\.]+)/){
	$U_list = $1;
	@U_values = split(/ +/, $U_list);
	} elsif (/J\s\(eV\)\s+.*LDAUJ =\s+([-\d\.]+.*[-\d\.]+)/){
	$J_list = $1;
	@J_values = split(/ +/, $J_list);
	}
    last POTENTIALS_LOOP if (/length of vectors/);
    }

# reads OUTCAR backwards to get the lines after the last minimisation
@outcar = (<OUTCAR_HANDLE>);
$x = @outcar -1;
until ( ($outcar[$x] =~ /aborting loop because EDIFF is reached/) || ($x ==0) ) {
	$line = $outcar[$x];
	unshift(@lines, $outcar[$x]);
	$x --;
    }
close OUTCAR_HANDLE;

# extracts data from the array @lines
$opt = $charge_opt = 0;
$n_line = -1;
foreach $line (@lines) {
	$n_line ++;
	if ($line =~ /Elapsed time \(sec\):\s+([-\d\.]+)/) {
		$time = $1;
	} elsif ($line =~ /volume of cell :\s+([-\d\.]+)/) {
		$vol_fin = $1;
	} elsif ($line =~ /energy-cutoff  :\s+([-\d\.]+)/) {
		$cutoff = $1;
	} elsif ($line =~ /free  energy   TOTEN  =\s+([-\d\.]+)/) {
		$free_E = $1;
	} elsif ($line =~ /external pressure =\s+([-\d\.]+) kB  Pullay stress =\s+([-\d\.]+)/) {
		$external_pressure = $1;
		$Pulay_stress = $2;
	} elsif ($line =~ /length of vectors/) {
		@latt_vectors = split(/ +/, $lines[$n_line + 1]);
		$a_fin = $latt_vectors[1];
		$b_fin = $latt_vectors[2];
		$c_fin = $latt_vectors[3];
		$c_a_ratio = $c_fin/$a_fin;
	} elsif ($line =~ /total charge/) {
	$charge_opt = 1;
	$opt = 1;
	} elsif ($line =~ /magnetization/) {
	$opt = 0;
	}
	if (($opt ==1) && ($line =~ /[-\d\.]+/)) {
	$line =~ s%^\s+%%g;
	push (@final_charges,$line);
	}
}

#The following part compares POSCAR and CONTCAR atom positions
$poscar_location = "$cwd/POSCAR";
open(POSCAR_HANDLE, "<$poscar_location") or print "failed to open POSCAR\n";
@poscar = <POSCAR_HANDLE>;
close POSCAR_HANDLE;
foreach $poscar_line (@poscar) {
	$poscar_line =~ s%^\s+%%g;
}
@contcar = @poscar;
$contcar_location = "$cwd/CONTCAR";
#open(CONTCAR_HANDLE, "<$contcar_location") or print "failed to open CONTCAR\n";
#@contcar = <CONTCAR_HANDLE>;
#close CONTCAR_HANDLE;
#foreach $contcar_line (@contcar) {
#	$contcar_line =~ s%^\s+%%g;
#}

$opt = $length_sum = $length = $max_disp = 0;
$n_contcar_line = -1;
$n_current_atom = $n_atom_type_count = 1;

# This code get the lattice matrix, and the number list of atom types.
@atom_numbers = split(/\s+/, $contcar[5]);
$current_atom_type_index = shift(@atom_numbers);
@latt_matrix_r1 = split(/\s+/, $contcar[2]);
@latt_matrix_r2 = split(/\s+/, $contcar[3]);
@latt_matrix_r3 = split(/\s+/, $contcar[4]);

$LATT_matrix = Math::MatrixReal->new_from_string(<<"LATT_MATRIX");
[ $latt_matrix_r1[0] $latt_matrix_r1[1] $latt_matrix_r1[2] ]
[ $latt_matrix_r2[0] $latt_matrix_r2[1] $latt_matrix_r2[2] ]
[ $latt_matrix_r3[0] $latt_matrix_r3[1] $latt_matrix_r3[2] ]
LATT_MATRIX
# Transpose the Latt_matrix - needing this depends on how you have specified the matrix and coord vectors!!
$LATT_matrix->transpose($LATT_matrix);

# This loop gets the format of atom coordinates in POSCAR and CONTCAR. It looks for the line"Direct" or "Cart"
if ($poscar[6] =~ /^[Dd]/) {
    $coord_type_poscar = "frac";
	} elsif ($poscar[6] =~ /^[KCkc]/) {
	$coord_type_poscar = "cart";
	} elsif ($poscar[7] =~ /^[Dd]/) {
    $coord_type_poscar = "frac";
	} elsif ($poscar[7] =~ /^[KCkc]/) {
	$coord_type_poscar = "cart";
	} else {
	die "\nXXXX\n\ncouldn't establish coordinate type in POSCAR, fractional or cartesian\n\nXXXX\n";
	}

if ($contcar[6] =~ /^[Dd]/) {
    $coord_type_contcar = "frac";
	} elsif ($contcar[6] =~ /^[KCkc]/) {
	$coord_type_contcar = "cart";
	} elsif ($contcar[7] =~ /^[Dd]/) {
    $coord_type_contcar = "frac";
	} elsif ($contcar[7] =~ /^[KCkc]/) {
	$coord_type_contcar = "cart";
	} else {
	die "\nXXXX\n\ncouldn't establish coordinate typein CONTCAR, fractional or cartesian\n\nXXXX\n";
	}

POSCARLOOP: for ($n_contcar_line = 7; $n_contcar_line <= @poscar; $n_contcar_line++) {
    $contcar_line = $contcar[$n_contcar_line];
	$displacement = new Math::MatrixReal(3,1);
	last POSCARLOOP if ($contcar_line !~ /[-\d\.]+/);
	@new_coords = split(/\s+/, $contcar_line);

	$poscar_line = $poscar[$n_contcar_line];
	if ($poscar_line =~ /[-\d\.]+\s+[-\d\.]+\s+[-\d\.]+/) {
		@orig_coords = split(/\s+/, $poscar_line);
	} else {
		print "error matching line number $n_contcar_line in POSCAR and CONTCAR\n";
		die;
	}

# These if statements convert cartesian coordinates to fractional coordinates
if ($coord_type_poscar eq "cart") {
    $orig_coord_vector = &convert_cartesian($orig_coords[0], $orig_coords[1], $orig_coords[2], $LATT_matrix);
    $orig_coords[0] = $orig_coord_vector->element(1,1);
    $orig_coords[1] = $orig_coord_vector->element(2,1);
    $orig_coords[2] = $orig_coord_vector->element(3,1);
}
if ($coord_type_contcar eq "cart") {
    $new_coord_vector = &convert_cartesian($new_coords[0], $new_coords[1], $new_coords[2], $LATT_matrix);
    $new_coords[0] = $new_coord_vector->element(1,1);
    $new_coords[1] = $new_coord_vector->element(2,1);
    $new_coords[2] = $new_coord_vector->element(3,1);
    }

	# This loop calculates the displacment vector and normalises atoms that have been shifted across cell boundaries and re-coordinated automatically by vasp
	for ($x = 0; $x <=2; $x ++) {
		if ( (sqrt($new_coords[$x]**2) < 0.1) && (sqrt($orig_coords[$x]**2) > 0.9) ) {
			$disp_element[$x] = $new_coords[$x] - $orig_coords[$x] + 1;
		} elsif ( (sqrt($orig_coords[$x]**2) < 0.1) && (sqrt($new_coords[$x]**2) > 0.9)) {
			$disp_element[$x] = $new_coords[$x] - $orig_coords[$x] - 1;
		} else {
			$disp_element[$x] = $new_coords[$x] - $orig_coords[$x];
		}
	}

	# the displacement vector is turned into cartesian coordinates to give the true length
	$displacement=&convert_fractional($disp_element[0], $disp_element[1], $disp_element[2], $LATT_matrix);
	$length = $displacement->length();

	# rest of the script pulls out charge data and sums the lengths moved per atom type
	if ($charge_opt == 1) {
		@atom_charge = split(/\s+/, $final_charges[$n_current_atom]);
		pop(@atom_charge);
		shift(@atom_charge);
		if (defined($atom_charge[0])) {$s_charge_sum += $atom_charge[0]};
		if (defined($atom_charge[1])) {$p_charge_sum += $atom_charge[1]};
		if (defined($atom_charge[2])) {$d_charge_sum += $atom_charge[2]};
		if (defined($atom_charge[3])) {$f_charge_sum += $atom_charge[3]};
	}
	if ($length > $max_disp) {
		$max_disp = $length;
		if ($charge_opt == 1) {
			@atom_charge = split(/\s+/, $final_charges[$n_current_atom]);
			pop(@atom_charge);
			shift(@atom_charge);
			if (defined($atom_charge[0])) {$s_charge = $atom_charge[0]} else {$s_charge = 0};
			if (defined($atom_charge[1])) {$p_charge = $atom_charge[1]} else {$p_charge = 0};
			if (defined($atom_charge[2])) {$d_charge = $atom_charge[2]} else {$d_charge = 0};
			if (defined($atom_charge[3])) {$f_charge = $atom_charge[3]} else {$f_charge = 0};
			$max_disp_ion_info = sprintf("number_of_max\.disp_atom $n_current_atom  coords_of_max\.disp_atom %.8f %.8f %.8f  charges_on_max\.disp_atom s %.3f  p %.3f  d %.3f  f %.3f  ",$new_coords[0], $new_coords[1], $new_coords[2], $s_charge, $p_charge, $d_charge, $f_charge);
		} else {
			$max_disp_ion_info = sprintf("number_of_max\.disp_atom $n_current_atom  coords_of_max\.disp_atom %.8f %.8f %.8f  no_atomic_charge_data_found s xxx p xxx d xxx f xxx ", $new_coords[0], $new_coords[1], $new_coords[2]);
		}
	}

	$length_sum += $length;
	$n_atom_type_count ++;
	if ($n_atom_type_count > $current_atom_type_index) {
		$avr_disp = $length_sum/$current_atom_type_index;
		if ($charge_opt == 1) {
			$s_charge_avr = $s_charge_sum/$current_atom_type_index;
			$p_charge_avr = $p_charge_sum/$current_atom_type_index;
			$d_charge_avr = $d_charge_sum/$current_atom_type_index;
			$f_charge_avr = $f_charge_sum/$current_atom_type_index;
			$avr_charge_info = sprintf("avr_ion_chrgs s %.5f  p %.5f  d %.5f  f %.5f ", $s_charge_avr, $p_charge_avr, $d_charge_avr, $f_charge_avr);
		} else {
			$avr_charge_info = "no_atomic_charge_data_found s xxx  p xxx  d xxx f xxx ";
		}
		$potential = shift(@potentials)." U_affect ".shift(@U_affects)." U ".shift(@U_values)." J ".shift(@J_values);
		$intro .= "$potential  ";
		$result_displacements .= sprintf(" ATOM %s \(x%d\) avr\.disp\(ang\) %.8e  %s  max\.disp\.ion\(ang\) %.8e  %s  ", $potential, $current_atom_type_index, $avr_disp, $avr_charge_info, $max_disp, $max_disp_ion_info);
		$current_atom_type_index = shift(@atom_numbers);
		$n_atom_type_count = 1;
		$length = $length_sum = $max_disp = $s_charge = $p_charge = $KineticE_error_per_atom_n_atom = $d_charge = $f_charge = $s_charge_sum = $p_charge_sum = $d_charge_sum = $f_charge_sum = 0;
	}
	$n_current_atom ++;
}

$cwd =~ tr%\/% %;

# use bandgap.pl to find bandgap data and pass it into this script
$band_info = `~/bin/vtstscripts/bandgap.pl -sp 1`;

$result = "$intro $selected_file  TIME\(s\) $time Cut_off\(eV\)  $cutoff  No\._k-points $n_kpoints  RESULTS  Energy\(eV\)  $free_E  Pulay_stress\(kB\)  $Pulay_stress Ext_pressure\(kB\) $external_pressure  VOL\(ang\)  $vol_fin  c_a-ratio $c_a_ratio a_cell $a_fin  b_cell  $b_fin  c_cell  $c_fin  $band_info $result_displacements Directory $cwd";
system("~/bin/vtstscripts/bandgap.pl");

print OUT_RESULTS "$result\n";

}
}
}


