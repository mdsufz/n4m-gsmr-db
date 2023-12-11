# load Java module
module load GCCcore/10.2.0 ANTLR/2.7.7-Java-11

# run BBtools Statswrapper on each MAG and store in output folder
for f in /work/magnusdo/evoniche/mags/*.fa; do
    /gpfs1/data/msb/tools/bbtools/bbmap/statswrapper.sh "$f" | tail -n +2 >> /work/magnusdo/evoniche/bbtools.tsv
done
