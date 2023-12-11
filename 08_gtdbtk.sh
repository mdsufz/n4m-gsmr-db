#!/bin/bash

#SBATCH --job-name=gtdbtk
#SBATCH --output=/work/%u/evoniche/logs/rk_gtdbtk.out
#SBATCH --error=/work/%u/evoniche/logs/rk_gtdbtk.err
#SBATCH --time 120:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task 40

#module load Anaconda3

# loading conda environment
source activate /gpfs1/data/msb/tools/miniconda3/envs/mudoger_env
config_path="$(which config.sh)"
database="${config_path/config/database}"
source $config_path
source $database

# load gtdbtk env
conda activate "$MUDOGER_DEPENDENCIES_ENVS_PATH"/gtdbtk_env

GTDBTK_DATA_PATH=$(realpath "$DATABASES_LOCATION"gtdbtk/release*)

export GTDBTK_DATA_PATH=$GTDBTK_DATA_PATH

pip list
conda list

#######
gtdbtk classify_wf --genome_dir /work/magnusdo/evoniche/rk_mags/rk_mags_simple --out_dir /work/magnusdo/evoniche/rk_mags/GTDBtk_taxonomy --cpus ${SLURM_CPUS_PER_TASK:-1}

if [ -f /work/magnusdo/evoniche/rk_mags/GTDBtk_taxonomy/gtdbtk.bac120.summary.tsv ] || [ -f /work/magnusdo/evoniche/rk_mags/GTDBtk_taxonomy/gtdbtk.ar53.summary.tsv ]; 
then awk 'FNR==1 && NR!=1 {next;}{print}' /work/magnusdo/evoniche/rk_mags/GTDBtk_taxonomy/gtdbtk.*summ*.tsv > /work/magnusdo/evoniche/rk_mags/GTDBtk_taxonomy/gtdbtk_result.tsv;
echo "GTDBtk results generated!"
else
echo "Error: GTDBtk summary files not found"
fi

conda deactivate
