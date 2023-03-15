#!/bin/bash

#This program will run tiptoft for plasmid prediction using uncorrected ONT long reads.

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "			-i path/to/reads/		reads in fastq or fastq.gz format"
echo ""
echo "Example: $0 -i path/to/uncorrectedreads.fastq.gz"
echo ""
exit 0
}

#Take arguments
#Run HELP if -h -? or invalid input
while getopts ":hi:" option; do
	case ${option} in
		h)
		HELP
		;;
		i)
		export LONGREADS=${OPTARG}	
		\?)
		echo "Invalid option: ${OPTARG}" 1>&2
		HELP
		;;
	esac
done

#Check if all parameters are filled
if [[ -z "${LONGREADS}" ]]; then
	echo ""
	echo "All flags required."
	HELP
fi

#Check if files exist and print out variables
if [[ -e $LONGREADS ]]; then
	echo ""
	echo "$0"
	echo "Input reads set to:" ${LONGREADS}
	echo ""
else
	echo ""
	echo "Could not validate files. Please check and try again."
	HELP
fi

#Run tiptoft via Singularity container, version 1.0.2 latest from staphb dockerhub repo as of 3/15/2023
#Download PlasmidFinder database
singularity exec --no-home -B $PWD:/data docker://staphb/tiptoft:1.0.2 tiptoft --version
#Run tiptoft
singularity exec --no-home -B $PWD:/data docker://staphb/tiptoft:1.0.2 tiptoft ${LONGREADS} -o tiptoft_results.txt

