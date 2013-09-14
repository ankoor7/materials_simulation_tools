#!/bin/bash

tar -zcvf backup_xmgrace_plots.tar.gz ./*pdf


module load grace intel-suite

find .  -maxdepth 1  -name "*agr" -exec grace -hardcopy  -hdevice "EPS" -free {} \;

module unload grace

find . -maxdepth 1 -name "*eps" -exec epstopdf {} \;

for i in *.eps
do
convert  $i ${i%.eps}.png
rm $i
done

