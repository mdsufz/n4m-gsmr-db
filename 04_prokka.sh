#!/bin/bash

#SBATCH --job-name=prokka
#SBATCH --output=/work/%u/evoniche/logs/%x-%A-%a.out
#SBATCH --error=/work/%u/evoniche/logs/%x-%A-%a.err
#SBATCH --time 72:00:00
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task 4

module load Anaconda3

# loading conda environment
source activate /gpfs1/data/msb/tools/miniconda3/envs/mudoger_env
config_path="$(which config.sh)"
database="${config_path/config/database}"
source $config_path
source $database

source activate "$MUDOGER_DEPENDENCIES_ENVS_PATH"/prokka_env

#######
for subtask_id in $(seq $SLURM_ARRAY_TASK_ID $(( $SLURM_ARRAY_TASK_ID + $SLURM_ARRAY_TASK_STEP - 1 )) )
do
    echo "Subtask $subtask_id of task $SLURM_ARRAY_TASK_ID"

    ################## INPUTS
    # get list of input IDs from first argument
    sampleList="$1"

    ################## INPUT FOR THIS TASK
    # this is the n-th (where n is current task ID) line of the file
    # input_id=$(awk '{if(NR==$SLURM_ARRAY_TASK_ID) print $0}' $input_ids)
    sample=$(awk "NR==$subtask_id" "$sampleList")

    ################## Run script
    prokka /work/magnusdo/evoniche/mags/"$sample" --cpus ${SLURM_CPUS_PER_TASK:-1} --outdir /work/magnusdo/evoniche/prokka --prefix "$sample" --force
done

