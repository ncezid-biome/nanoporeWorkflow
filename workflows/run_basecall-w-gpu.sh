#!/bin/bash
# Curtis Kapsak, created May 2019

# This is the driver script for np_basecall-w-gpu.sh script. It takes in 5 arguments and
# submits jobs to the cluster for GPU basecalling with Guppy and run QC with NanoPlot

#This function will check to make sure the directory doesn't already exist before trying to create it
make_directory() {
    if [ -e $1 ]; then
        echo "Directory "$1" already exists"
    else
        mkdir -pv $1
    fi
}

function HELP {
echo ""
echo "Usage: $0 "
echo "                 -i path/to/fast5files/        searches recursively for fast5 files"
echo "                 -o path/to/outputDirectory/   output directory"
echo "                 -b y || yes || n || no        barcodes used?"
echo "                 -f r941 || r10                flowcell type used?"
echo "                 -k rapid || ligation          sequencing kit used?"
echo ""
echo "example: $0 -i fast5s/ -o output/ -b y -f r941 -k rapid"
echo ""
exit 0
}

### take in flags and arguments
# print help options if -h is used or if invalid input
# set input fast5dir (-i) and outdir (-o)
# determine whether barcodes were used (-b) and what flowcell was used (-f)
# set sequencing kit with -k
while getopts ":hi:o:b:f:k:" opt; do
  case ${opt} in
    h )
      HELP
      ;;
    i ) # set input dir of fast5 files
      export FAST5DIR=${OPTARG}
      ;;
    o ) # set output dir
      make_directory ${OPTARG}
      export OUTDIR=${OPTARG}
      ;;
    b )
      # if y or yes , set BARCODE to yes
      if [[ "${OPTARG}" == "y" || "${OPTARG}" == "yes" ]]; then
        export BARCODE=yes
      # if n or no , set BARCODE to no
      elif [[ "${OPTARG}" == "n" || "${OPTARG}" == "no" ]]; then
        export BARCODE=no
      else
        echo "Invalid argument "${OPTARG}" for -b flag. Use: y || yes || n || no" 1>&2
        HELP
      fi
      ;;
    f ) # set flowcell used
      if [[ "${OPTARG}" == "r941" ]]; then
        export FLOWCELL=r941
      elif [[ "${OPTARG}" == "r10" ]]; then
        export FLOWCELL=r10
      else
        echo "Invalid argument "$OPTARG" for -f flag. Use: r941 || r10" 1>&2
        HELP
      fi
      ;;
    k ) # set sequencing kit used
      if [[ "${OPTARG}" == "ligation" ]]; then
        export SEQKIT=ligation
      elif [[ "${OPTARG}" == "rapid" ]]; then
        export SEQKIT=rapid
      else
        echo "Invalid argument "$OPTARG" for -k flag. Use: rapid || ligation" 1>&2
        HELP
      fi
      ;;
    : )
      echo "Error: -${OPTARG} requires an argument."
      HELP
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      HELP
      ;;
  esac
done
shift $((OPTIND -1))

# sanity check
echo 'FAST5DIR is set to: ' ${FAST5DIR}
echo 'OUTDIR is set to: ' ${OUTDIR}
echo '$BARCODE set to: ' ${BARCODE}
echo '$FLOWCELL set to: ' ${FLOWCELL}
echo '$SEQKIT set to: ' ${SEQKIT}

# if any input argments are empty/null strings, show help and exit script
if [[ -z "${FLOWCELL}" || -z "${BARCODE}" || -z "${FAST5DIR}" || -z "${OUTDIR}" || -z "${SEQKIT}" ]]; then
  echo "Error: All flags are required"
  echo "Please set them and re-run the script"
  HELP
fi

thisDir=$(dirname $0)

mkdir -pv ${OUTDIR}/log

# give guppy-gpu job a unique name
uuid1=$(uuidgen)
jobName1="guppy-gpu-$uuid1"

# call the actual basecalling script
# no need to pass variables since they are exported when set above
# qsub will put logs into OUTDIR/log for tidyness
qsub -N $jobName1 -q gpu.q -o ${OUTDIR}/log/guppy.log -j y ${thisDir}/../scripts/np_basecall-w-gpu.sh

# give nanoplot job a unique name
uuid2=$(uuidgen)
jobName2="nanoplot-$uuid2"

qsub -N $jobName2 -hold_jid $jobName1 -o ${OUTDIR}/log/nanoplot.log -j y ${thisDir}/../scripts/np_qc_nanoplot.sh
