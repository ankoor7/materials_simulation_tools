#!/usr/bin/perl -w

#Location of the perl modules in the hpc "/export4/home/ap1702/lib/perl5/"
BEGIN {
push @INC,"/home/ap1702/lib/perl5";
}
                    
use Math::MatrixReal;
use Getopt::Long;

my $silent = 0;
GetOptions (  "silent" =>\$silent);



foreach my $cmd (glob "*.o*"){
  print "scanning file ".$cmd."\n";
   &LATTICE($cmd);
   &DEFECT($cmd);
  }


sub LATTICE
{
my ($file) = @_;
@elas_line1 = ();
@elas_line2 = ();
@elas_line3 = ();
@elas_line4 = ();
@elas_line5 = ();
@elas_line6 = ();


  # reset defaults
  $energy = "";
  $isenergy = "no";
  $problem = "no";

  # open file
  open FILE, "$file";
  @file = <FILE>;
  close FILE;
  # scan file
  $stop = scalar(@file);
  for ($n_line = 0; $n_line <= $stop-1; $n_line++) {
  $line = $file[$n_line];
     
    if ($line =~ /\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\s*(\S+)/) {
      $title = $1;
      chomp($title);
     }
    {
    if ($line =~ /^.* LATTICE ENERGY IS\s*(\S*).*$/)
     {
      $energy = $1;
      $isenergy = "yes";   
     }
    if ($line =~ /^.*INVALID.*$/)
     {
      $problem = "yes";   
     }
    }
   if ($line =~ /FINAL LATTICE VECTORS ARE/) {
	$X = $file[$n_line + 1];
	$X =~ s%\n%%g;
	$Y = $file[$n_line + 2];
	$Y =~ s%\n%%g;
	$Z = $file[$n_line + 3];
	$Z =~ s%\n%%g;
   } elsif ($line =~ /LATTICE CONSTANT =\s+([-\d\.]+)/) {
  	$latt_const = $1;
   } elsif ($line =~ /ELASTIC CONSTANT TENSOR/) {
	chomp($file[$n_line + 1]);
	@elas_line1 = split(/ +/, $file[$n_line + 1]);
        chomp($file[$n_line + 2]);
        @elas_line2 = split(/ +/, $file[$n_line + 2]);
        chomp($file[$n_line + 3]);
        @elas_line3 = split(/ +/, $file[$n_line + 3]);
        chomp($file[$n_line + 4]);
        @elas_line4 = split(/ +/, $file[$n_line + 4]);
        chomp($file[$n_line + 5]);
        @elas_line5 = split(/ +/, $file[$n_line + 5]);
        chomp($file[$n_line + 6]);
        @elas_line6 = split(/ +/, $file[$n_line + 6]);

   }	
 }

$elastic_const = " elastic_GPa row_1 @elas_line1 row_2 @elas_line2 row_3 @elas_line3 row_4 @elas_line4 row_5 @elas_line5 row_6 @elas_line6";
shift(@elas_line1);
shift(@elas_line2);
shift(@elas_line3);
shift(@elas_line4);
shift(@elas_line5);
shift(@elas_line6);

foreach $const (@elas_line1) {
$const = $const*10;
}
foreach $const (@elas_line2) {
$const = $const*10;
}
foreach $const (@elas_line3) {
$const = $const*10;
}
foreach $const (@elas_line4) {
$const = $const*10;
}
foreach $const (@elas_line5) {
$const = $const*10;
}
foreach $const (@elas_line6) {
$const = $const*10;
}

$elastic_const = " elastic_GPa row_1 @elas_line1 row_2 @elas_line2 row_3 @elas_line3 row_4 @elas_line4 row_5 @elas_line5 row_6 @elas_line6";

foreach $const (@elas_line1) {
$const = $const*0.0062415097400;
}
foreach $const (@elas_line2) {
$const = $const*0.0062415097400;
}
foreach $const (@elas_line3) {
$const = $const*0.0062415097400;
}
foreach $const (@elas_line4) {
$const = $const*0.0062415097400;
}
foreach $const (@elas_line5) {
$const = $const*0.0062415097400;
}
foreach $const (@elas_line6) {
$const = $const*0.0062415097400;
}

$elastic_matrix = Math::MatrixReal->new_from_string(<<"MATRIX");
[ $elas_line1[0] $elas_line1[1] $elas_line1[2] $elas_line1[3] $elas_line1[4] $elas_line1[5] ]
[ $elas_line2[0] $elas_line2[1] $elas_line2[2] $elas_line2[3] $elas_line2[4] $elas_line2[5] ]
[ $elas_line3[0] $elas_line3[1] $elas_line3[2] $elas_line3[3] $elas_line3[4] $elas_line3[5] ]
[ $elas_line4[0] $elas_line4[1] $elas_line4[2] $elas_line4[3] $elas_line4[4] $elas_line4[5] ]
[ $elas_line5[0] $elas_line5[1] $elas_line5[2] $elas_line5[3] $elas_line5[4] $elas_line5[5] ]
[ $elas_line6[0] $elas_line6[1] $elas_line6[2] $elas_line6[3] $elas_line6[4] $elas_line6[5] ]
MATRIX
#print $elastic_matrix."\n";
$elastic_inverse = $elastic_matrix->inverse;
#print $elastic_inverse."\n";

%compliance_const = ();
$isothermal_compressibilty =0;
for ($i=1;$i<=3;$i++) {
for ($j=1;$j<=3;$j++) {
$isothermal_compressibilty += $elastic_inverse->element($i,$j);
}
}
  
$cell = "latt_const_Ang ".$latt_const." X ".$X." Y ".$Y." Z ".$Z;
  # decide what to say
  if ($isenergy eq "yes" && $problem eq "no")
    {
    $output = sprintf ("$file $title LATT_E %.4f eV $cell isotherm_compressilbilty-eV_ang $isothermal_compressibilty $elastic_const", $energy);
    $printed_output = sprintf ("$file $title LATT_E %.4f eV $cell isotherm_compressilbilty-eV_ang $isothermal_compressibilty $elastic_const", $energy);
    }
  elsif ($isenergy eq "no" && $problem eq "no")
    {
  $output = "$file $title NO LATICE ENERGY FOUND";
  $printed_output = "$file $title NO LATTICE ENERGY FOUND";  
  }
  elsif ($problem eq "yes")
    {
  $output = sprintf ("$file $title has an PROBLEM please check (LE = %.4f)", $energy);
  $printed_output = sprintf ("$file $title has an PROBLEM please check (LE = %.4f)", $energy);
    }
    unless ($silent == 1 ) {print $output;}
    open OUT, ">>results";
    print OUT $printed_output;
    close OUT;
}

# process file for defect energy
sub DEFECT
{
my ($file) = @_;

  # reset defaults
  $energy = "";
  $isenergy = "no";
  $problem = "no";

  # open file
  open FILE, "$file";
  @file = <FILE>;
  close FILE;
$n_line = 0;
$info_finished = 0;
$extract_BLEN = 0;
@BLEN_out = ();
$n_atom = 0;
  # scan file
DEFECT_LINES:  foreach $line (@file)
    {
    if ($line =~ /\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\*\s*(\S+)/) { 
        $title = $1;
        chomp($title);
     }
    if ($line =~ /NUMBER OF CLASSES IN REGION I =\s*(\d*)/) {
	$reg1_classes = $1;
     }
    if ($line =~ /NUMBER OF SPECIES \(CORES \+ SHELLS\) IN REGION I =\s*(\d*)/) {
        $reg1_species = $1;
     }
    if ($line =~ /^0CLASS LIST OF VACANCIES/) {
        @vaca_initial = split(/ +/, $file[$n_line + 4]);
     }
     if ($line =~ /^0CLASS LIST OF INTERSTITIALS/) {
        @inte_initial = split(/ +/,$file[$n_line+4]);
     }
    if ($line =~ /^.*FINAL ENERGY OF DEFECT   =\s*(\S*).*$/) {
        $energy = $1;
        $isenergy = "yes"; 
        $info_finished = 1;
     }
     if (($line =~/INTERSTITIAL CLASSES/) and ($info_finished = 1)) {
        @inte_final = split(/ +/,$file[$n_line+6]);
     }
    if ($line =~ /^.*INVALID.*$/) {
        $problem = "yes";   
     }
    if ($line =~/LENGTHS/ && $extract_BLEN == 1) {
        $extract_BLEN = 2;
     }
    if ($line =~ /CORE/ && $extract_BLEN == 1) {
        @BLEN_data =();
        @BLEN_data = split(/ +/, $line);
        push (@BLEN_out, sprintf("$BLEN_data[1] %.8f %.8f %.8f\n", $BLEN_data[3]*$latt_const, $BLEN_data[4]*$latt_const, $BLEN_data[5]*$latt_const));
        $n_atom ++;
     }
     if ($line =~/BOND LENGTHS FROM ION/ && $extract_BLEN == 0) {
        $extract_BLEN = 1;
        @BLEN_origin = split(/ +/, $line);
     }
    $n_line += 1; 
    }
    $blen_file = substr $title, 0, -4;
    $blen_file = $blen_file.".xyz";
    open BLEN, ">>$blen_file";
    unless ($silent == 1 ) {print BLEN "$n_atom\n$title\n";}
    foreach $l (@BLEN_out) {print BLEN "$l"};
    close BLEN;

  # decide what to say
  if ($isenergy eq "yes" && $problem eq "no")
    {
    $output = sprintf ("$file $title\n %.8f REG1_classes %.2f REG1_species %.2f\n\n", $energy, $reg1_classes, $reg1_species);
    $printed_output = sprintf ("$file $title %.8f eV - REG1_classes %.2f REG1_species %.2f \n", $energy, $reg1_classes, $reg1_species);
    }
  elsif ($isenergy eq "no" && $problem eq "no")
    {
  $output = "$file $title NO DEFECT ENERGY FOUND\n";
  $printed_output = "$file $title NO DEFECT ENERGY FOUND\n";
    }
  elsif ($problem eq "yes")
    {
  $output = sprintf ("$file $title has an PROBLEM please check (DE = %.4f)\n", $energy);
  $printed_output = sprintf ("$file  $title has an PROBLEM please check (DE = %.4f)\n", $energy);
    }
  unless ($silent == 1 ) {print $output;}
  open OUT, ">>results";
  print OUT $printed_output;
  close OUT;
}
