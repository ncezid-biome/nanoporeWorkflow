#!/bin/bash

#This script will house CDC-environment module loads

set -e

module purge
echo "Modules loaded:"
echo "singularity/3.5.3"
module load singularity/3.5.3
echo "guppy/4.4.2"
module load guppy/4.4.2
echo "minimap2/2.17"
module load minimap2/2.17
echo "racon/1.3.1"
module load racon/1.3.1
