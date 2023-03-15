#!/bin/bash

#This program will rotate the raw flye assembly's contigs to dnaA prior to consensus calling and polishing
#via Singularity container

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "			-a path/to/assembly/		draft assembly in .fasta format"
echo "			-p prefix			output files prefix name"
echo ""
echo "Example: $0 -a /path/to/flyeassembly.fasta -p flye.circ"
echo ""
exit 0
}

###Take arguments
#Run HELP if -h -? or invalid input
while getopts ":ha:p:" option; do
	case ${option} in
		h)
		HELP
		;;
		a)
		export ASSEMBLY=${OPTARG}
		;;
		p)
		export PREFIX=${OPTARG}
		;;	
		\?)
		echo "Invalid option: ${OPTARG}" 1>&2
		HELP
		;;
	esac
done

#Check if all parameters are filled
if [[ -z "${ASSEMBLY}" || -z "{PREFIX}" ]]; then
	echo ""
	echo "All flags required."
	HELP
fi

#Check if files exist and print out variables
if [[ -e $ASSEMBLY ]]; then
	echo ""
	echo "$0"
	echo "Draft assembly set to:" ${ASSEMBLY}
	echo ""
else
	echo ""
	echo "Could not validate files. Please check and try again."
	HELP
fi

#Run circlator via Singularity container, version 1.5.5 latest from staphb dockerhub repo as of 3/15/2023
echo "Rotating contigs with Circlator via Singularity container..."
singularity exec -B $PWD:/data docker://staphb/circlator:latest circlator version
singularity exec -B $PWD:/data docker://staphb/circlator:latest circlator fixstart ${ASSEMBLY} ${PREFIX}
