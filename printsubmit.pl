#! /usr/bin/perl -w

	$submit_script = "\#!/bin/sh\n\#PBS -l walltime=1:00:00 \n\#PBS -l select=1:ncpus=1:mem=920mb \nwork_dir=\"$TMPDIR\" \nmodule load mpi \nmodule load gulp \ngulp \< ".$filedir."/".$RE_ion."-".$struc_ion."-$PBS_ARRAY_INDEX".".glp \n";
	
	print "$submit_script";
