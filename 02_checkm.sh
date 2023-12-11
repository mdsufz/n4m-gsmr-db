# Installed checkm in a conda environment
module load Anaconda3
source activate checkm

# run checkm on all the MAGs in the given directory and store results in a checkm folder
# used 12 cores
checkm lineage_wf -t 12 /work/magnusdo/evoniche/mags /work/magnusdo/evoniche/checkm
