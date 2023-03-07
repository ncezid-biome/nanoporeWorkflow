#!/bin/bash

#This script will run nanoq to filter reads <1000bp using singularity

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "			-i path/to/reads			input reads in .fastq.gz format"
echo "			-l minimum length			reads below this length will be filtered out"
echo "			-o path/to/output			output filtered reads"
echo ""
echo "Example: $0 -i /path/to/reads -l 1000 -o path/to/output"
echo ""
exit 0
}

###Take arguments
#Run HELP if -h -? or invalid input
#Set READS to -i
#Set MINLENGTH to -l
#Set OUTPUT to -o
while getopts ":hi:l:o:" option; do
	case ${option} in
		h)
		HELP
		;;
		i)
		export READS=${OPTARG}
		;;
		l)
		export MINLENGTH=${OPTARG}
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
if [[ -z "${READS}" || -z "${MINLENGTH}" || -z "${OUTPUT}" ]]; then
	echo ""
	echo "All flags required."
	HELP
fi

#Check if files exist and print out variables
if [[ -e $READS ]]; then
	echo ""
	echo "$0"
	echo "Input reads set to: " ${READS}
	echo "Minimum length set to: " ${MINLENGTH}
	echo "Output file set to: " ${OUTPUT}
	echo ""
else
	echo ""
	echo "Could not validate files. Please check and try again."
	HELP
fi

thisDir=$(dirname $0)

#Run nanoq - for now version is stuck at 0.8.6
singularity exec -B $PWD:/data docker://jimmyliu1326/nanoq nanoq --version
singularity exec -B $PWD:/data docker://jimmyliu1326/nanoq nanoq -i ${READS} -l ${MINLENGTH} -o ${OUTPUT} -vvv -H >> nanoq.log 2>&1
