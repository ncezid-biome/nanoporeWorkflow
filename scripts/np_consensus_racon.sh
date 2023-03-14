#!/bin/bash

#this program will run align long reads to draft assembly using minimap2

#HELP function
function HELP {
echo ""
echo "Usage:" $0
echo "			-a path/to/assembly/			draft assembly in .fasta format"
echo "          -r path/to/reads/				reads in .fastq format"
echo "          -m mode							module vs container"
echo ""
echo "Example: $0 -a /path/to/draftassembly.fasta -r /path/to/longreads.fastq.gz -m container"
echo ""
exit 0
}

###Take arguments
#Run HELP if -h -? or invalid input
#Set ASSEMBLY to -a
#Set LONGREADS to -r
while getopts ":ha:r:m:" option; do
	case ${option} in
		h)
		HELP
		;;
		a)
		export ASSEMBLY=${OPTARG}
		;;
		r)
		export LONGREADS=${OPTARG}
		;;
		m)
		export MODE=${OPTARG}
		;;
		\?)
		echo "Invalid option: ${OPTARG}" 1>&2
		HELP
		;;
	esac
done

#Check if all parameters are filled
if [[ -z "${ASSEMBLY}" || -z "${LONGREADS}" || -z "${MODE}" ]]; then
	echo ""
	echo "All flags required."
	HELP
fi

#Check if files exist and print out variables
if [[ -e $ASSEMBLY || -e $LONGREADS ]]; then
	echo ""
	echo "$0"
	echo "Draft assembly set to:" ${ASSEMBLY}
	echo "Reads set to:" ${LONGREADS}
	echo ""
else
	echo ""
	echo "Could not validate files. Please check and try again."
	HELP
fi

#run minimap2 version 2.24, latest version available from staphb on dockerhub
echo "Aligning reads to draft assembly with minimap2..."
singularity exec -B $PWD:/data docker://staphb/minimap2:2.24 minimap2 --version
singularity exec -B $PWD:/data docker://staphb/minimap2:2.24 minimap2 -t 16 -x map-ont ${ASSEMBLY} ${LONGREADS} > alignment.paf

#If mode is set to "container" run racon version 1.4.3, latest version available from staphb on dockerhub
#If mode is set to "module" load and run racon/1.4.3 from scicomp module
#NOTE: You should only set -m to module if appropriate for your environment and you are running into hardware/OS compatibility issues with containers
echo "Running consensus calling with racon..."
if [[ "$MODE" == "container" ]]; then
	singularity exec -B $PWD:/data docker://staphb/racon:1.4.3 racon --version
	singularity exec -B $PWD:/data docker://staphb/racon:1.4.3 racon -m 8 -x -6 -g -8 -w 500 -t 16 ${LONGREADS} alignment.paf ${ASSEMBLY} > ctg.consensus.fasta
elif [[ "$MODE" == "module" ]]; then
	module purge
	module load racon/1.4.3
	racon -m 8 -x -6 -g -8 -w 500 -t 16 ${LONGREADS} alignment.paf ${ASSEMBLY} > ctg.consensus.fasta
fi
