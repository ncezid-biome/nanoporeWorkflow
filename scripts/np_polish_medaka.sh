#!/bin/bash

#This program will polish the racon draft assembly using medaka via Singularity container

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "	  -i path/to/reads/				path to reads"
echo "          -d path/to/draft/assembly			path to draft racon assembly"
echo "          -o path/to/output/dir/			output directory"
echo "          -m model					medaka model to match guppy basecaller"
echo ""
echo "Example: $0 -i /path/to/longreads.fastq -d /path/to/raconassembly.fasta -o path/to/output/dir -m r1041_e82_260bps_sup_g632"
echo ""
exit 0
}

###Take arguments
#Run HELP if -h -? or invalid input
#Set ASSEMBLY to -a
#Set LONGREADS to -r
while getopts ":hi:d:o:m:" option; do
	case ${option} in
		h)
		HELP
		;;
		i)
		export LONGREADS=${OPTARG}
		;;
		d)
		export ASSEMBLY=${OPTARG}
		;;
		o)
		export OUTPUT=${OPTARG}
		;;
		m)
		export MODEL=${OPTARG}
		;;
		\?)
		echo "Invalid option: ${OPTARG}" 1>&2
		HELP
		;;
	esac
done

# print medaka version; run medaka from ontresearch/medaka dockerhub repo: version 1.7.2 is latest as of 3/15/2023
singularity exec -B $PWD:/data docker://ontresearch/medaka:latest medaka --version

echo "Running Medaka via Singularity container..."
singularity exec -B $PWD:/data docker://ontresearch/medaka:latest medaka_consensus -i $LONGREADS -d $ASSEMBLY -o $OUTPUT -m $MODEL

