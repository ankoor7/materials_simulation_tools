#! /usr/bin/perl -w
#Author: Ankoor Patel
#Date: 7/12/09
#Purpose: starts watching the OSZICAR file for a job with the specified job_number on the Imperial HPC

no warnings "all";

BEGIN {
push @INC,"/home/ap1702/lib/perl5";
}

use Term::ANSIColor qw(:constants);
use Getopt::Long;
###################
###   OPTIONS   ###
###################
###################
$n_lines = '20';
$file = "OSZICAR";
$all = '1';
GetOptions ("all|a" => \$all,
            "lines|n|l=i" => \$n_lines,
            "file|f=s" => \$file);


# Report current jobs
$command = "qstat";
print "Current jobs:\n";
@info = `$command`;
if (@info=='') {
	print "none\n\n";
} elsif (@info!='') {
	shift(@info);shift(@info);
	print "@info";
	print "\n";  
}

# print file ending for all running jobs
if ($ARGV[0]=='') {
	$command = "qstat -r -n";
	@info = `$command`;
	shift(@info);shift(@info);shift(@info);shift(@info);shift(@info);
	$i = 0;
	# run through all running jobs
	foreach (@info) {
		# Get the server address and job id
		if ($info[$i] =~ /(\S*)\s*ap1702/) {
			$job_id = $1;
			$i++;
			if ($info[$i] =~ /\s*(cx1.\d+.\d+.\d+)\//) {			
				$server = $1;
				# print the job description
				$job_desc_command = "qstat -i $job_id";
				@job_desc = `$job_desc_command`;
				print BLUE, "$job_desc[2]$job_desc[3]$job_desc[4]", RESET;
				print "$job_desc[5]";
				print BLUE, "Server: $server\n", RESET;
				print "Begin $file output:\n", RESET;
				# Execute the follow command
				$follow = "ssh -n $server \'tail -n $n_lines /tmp/pbs.$job_id\/$file\'";
				system($follow);
				print "\n\n";
				$i++;
			}
		} else {
		$i++;
		}
	}		
} else { 
# print file ending for one specific job
	# Get the info from qstat the jobnumber is the remaining argument after GetOpt::Long has taken all the variables
	$command = "qstat -i $ARGV[0] -n";
	@info = `$command`;
	
	#print some of it for a header to the user
	print $info[3];
	print $info[4];
	print $info[5];
	
	# Get the server address and job id
	if ($info[6] =~ /\s*(cx1.\d+.\d+.\d+)\//) {
		$server = $1;
		print "Server: $server\nBegin $file output:\n";
		}
	if ($info[5] =~ /(\S*)\s*ap1702/) {
		$job_id = $1;
		}
	
	# Execute the follow command
	$follow = "ssh -n $server \'tail -n $n_lines -F /tmp/pbs.$job_id\/$file\'";
	exec($follow);
}
