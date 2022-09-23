#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -p molecule.psf -d trajectory.dcd"
   echo -e "\t-p PSF file to be used"
   echo -e "\t-d DCD file to be used"
   echo -e "\t-h Help"
   echo ""
   exit
}

if [ "$1" == "-h" ] ; then
    helpFunction
fi

while getopts "p:d:" flag
do
    case "$flag" in
        p) psfFile="$OPTARG" ;;
        d) dcdFile="$OPTARG" ;;
	?) helpFunction ;;
    esac
done 

if [ -z "$psfFile" ] || [ -z "$dcdFile" ]
then
   echo "";
   echo "Some or all of the parameters are empty";
   helpFunction
fi

echo "Input files:"; echo "";
echo "psfFile: $psfFile";
echo "dcdFile: $dcdFile";

echo ""; echo ""; echo "";

echo "Finding salt bridges..."; echo "";
module load vmd
vmd -dispdev text -psf $psfFile -dcd $dcdFile -e ./required_files/sb_script.tcl

echo ""; echo ""; echo "";

echo "Sorting through salt bridge data..."
module load R
Rscript ./required_files/salt_bridges.R

echo ""; echo ""; echo "";

echo "Cleaning up..."
rm *.dat
rmdir Plots

echo ""; echo ""; echo "";

echo "Success!"
