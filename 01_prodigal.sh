# load module
module load GCCcore/10.2.0 prodigal/2.6.3

# genome is a fasta file (genome.fa)
prodigal -i "$genome" -o "${genome/.fa/.gbk}" -a "${genome/.fa/.faa}"
