#!/bin/bash

#This script will take the output from np_downsample_rasusa.sh and assembly using flye

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "			-r /path/to/reads 			path to filtered, downsampled reads"
echo "			-g genome 					size of genome e.g. 4.8MB"
echo "			-o /path/to/output/			output directory"
echo ""
echo "Example: $0 -r /path/to/reads -g 4.8m -o path/to/output/directory/"
echo ""
exit 0
}

###Take arguments
#Run HELP if -h -? or invalid input
#Set GENOMESIZE to -g
#Set COVERAGE to -c
#Set READS to -i
#Set OUTPUT to -o
while getopts ":hr:g:o:" option; do
	case ${option} in
		h)
		HELP
		;;
		r)
		export READS=${OPTARG}
		;;
		g)
		export GENOMESIZE=${OPTARG}
		;;
		o)
		export OUTPUT=${OPTARG}
		;;
		\?)
		echo "Invalid option: ${OPTARG}" 1>&2
		HELP
		;;
	esac
done

#Check if all parameters are filled
if [[ -z "${READS}" || -z "${GENOMESIZE}" || -z "${OUTPUT}" ]]; then
	echo ""
	echo "All flags required."
	HELP
fi

#Check if files exist and print out variables
if [[ -e $READS ]]; then
	echo ""
	echo "$0"
	echo "Genome size set to:" ${GENOMESIZE}
	echo "Output directory set to: " ${OUTPUT}
	echo ""
else
	echo ""
	echo "Could not validate files. Please check and try again."
	HELP
fi

#Run flye version 2.9, latest available from staphb dockerhub repo as of 3/7/2023
#NOTE: Params set to --nano-hq which means you need ONT high-quality reads: Guppy5+ SUP or Q20 (<5% error)
#Change to --nano-raw for anything pre-Guppy4, --nano-corr for corrected reads
#For more information on flye usage: https://github.com/fenderglass/Flye/blob/flye/docs/USAGE.md
singularity exec -B $PWD:/data docker://staphb/flye:2.9 flye --version
singularity exec -B $PWD:/data docker://staphb/flye:2.9 flye --nano-hq $READS -g $GENOMESIZE -o $OUTPUT