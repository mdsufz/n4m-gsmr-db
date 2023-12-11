#!/bin/bash

#SBATCH --job-name=memote
#SBATCH --output=/work/%u/evoniche/logs/%x-%A-%a.out
#SBATCH --error=/work/%u/evoniche/logs/%x-%A-%a.err
#SBATCH --time 24:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --cpus-per-task 8

module load Anaconda3
source activate carvemep37
# manage threads
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-1}
# cplex
export PYTHONPATH=/data/msb/PEOPLE/stefania/CPLEX_Studio221/cplex/python/3.7/x86-64_linux

python --version

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
    memote report snapshot --filename /work/magnusdo/evoniche/memote_reports/"${sample/.xml/.html}" /work/magnusdo/evoniche/reconstructions_prodigal/"$sample"
done

