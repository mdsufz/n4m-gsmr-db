#!/bin/bash

module load Anaconda3
# conda init bash
source /software/easybuild-broadwell/software/Anaconda3/2020.07/etc/profile.d/conda.sh
# conda deactivate
conda activate carvemep37
which python

# export PYTHONPATH=/data/msb/PEOPLE/stefania/CPLEX_Studio221/cplex/python/3.7/x86-64_linux
# cd /data/msb/PEOPLE/stefania/CPLEX_Studio221/cplex/python/3.7/x86-64_linux/
# python setup.py install --home /magnusdo/.conda/envs/carvemep37/lib/python3.7/site-packages/cplex
export PYTHONPATH=/data/msb/PEOPLE/stefania/CPLEX_Studio221/cplex/python/3.7/x86-64_linux

# /home/magnusdo/.conda/envs/carvemep37/bin/python3.7 --version
# echo $PATH

MAG="$1"

python /home/magnusdo/.conda/envs/carvemep37/lib/python3.7/site-packages/carveme/cli/carve.py -g M3 --mediadb /work/magnusdo/media_db.tsv /work/magnusdo/evoniche/prodigal/proteins/"$MAG" --cobra --threads "$2" --output /work/magnusdo/evoniche/reconstructions/"${MAG/.faa/.xml}"

