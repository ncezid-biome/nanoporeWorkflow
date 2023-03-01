#!/bin/bash

#This script will run rasusa to randomly downsample reads to a target coverage.
#In workflow runs after read length filtering by nanoq

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "			-g genome 					size of genome e.g. 4.8MB"
echo "			-c coverage					target coverage"
echo "			-i /path/to/input/reads		input reads in fastq format"
echo "			-o /path/to/output/reads	output name"
echo ""
echo "Example: $0 -g 4.8MB -c 120 -i reads_all_nanoq.fastq -o reads_all_nanoq_rasusa.fastq"
echo ""
exit 0
}

###Take arguments
#Run HELP if -h -? or invalid input
#Set GENOMESIZE to -g
#Set COVERAGE to -c
#Set READS to -i
#Set OUTPUT to -o
while getopts ":hg:c:i:o:" option; do
	case ${option} in
		h)
		HELP
		;;
		g)
		export GENOMESIZE=${OPTARG}
		;;
		c)
		export COVERAGE=${OPTARG}
		;;
		i)
		export READS=${OPTARG}
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
if [[ -z "${GENOMESIZE}" || -z "${COVERAGE}" || -z "${READS}" || -z "${OUTPUT}" ]]; then
	echo ""
	echo "All flags required."
	HELP
fi

#Check if files exist and print out variables
if [[ -e $READS ]]; then
	echo ""
	echo "$0"
	echo "Genome size set to:" ${GENOMESIZE}
	echo "Target coverage set to:" ${COVERAGE}
	echo "Input reads set to: " ${READS}
	echo "Output file set to: " ${OUTPUT}
	echo ""
else
	echo ""
	echo "Could not validate files. Please check and try again."
	HELP
fi

thisDir=$(dirname $0)

#Run rasusa
singularity exec -B $PWD:/data ${thisDir}/../singularity/rasusa.0.7.0.sif rasusa -g ${GENOMESIZE} -c ${COVERAGE} -i ${READS} -o ${OUTPUT}