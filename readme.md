# Scripts used in the project "Analyses of over 60 thousand genome-scale metabolic models reveal phylogenetic conservations of r/K-strategies within the archaeal and prokaryotic phylogenetic trees"
Authors:  Ulisses Nunes da Rocha, Avila Santos Anderson Paulo, Sanchita Kamath, Victor Pylro, Stefanía Magnúsdóttir, CLUE-TERRA consortium

## Protein-coding genes (01_prodigal.sh)
Using Prodigal (https://github.com/hyattpd/Prodigal) to predict protein-coding genes in the genomes provided in fasta format.

## MAG quality check (02_checkm.sh)
Checking metagenome-assembled genome (MAG) quality using CheckM (https://ecogenomics.github.io/CheckM/).

## MAG sequence information (03_bbmap.sh)
Collecting technical information on all MAG sequences (e.g., number of scaffolds, GC content, etc.) using the Statswrapper tool from BBmap (https://github.com/BioInfoTools/BBMap).

## Protein annotation (04_prokka.sh)
Using Prokka (https://github.com/tseemann/prokka) to annotate the proteins because the Prodigal results do not contain annotations. Used this data to calculate the proportion of annotated proteins in each genome.

## Create genome-scale metabolic reconstructions (05_carveme.sh)
Use CarveMe (https://github.com/cdanielmachado/carveme) to create genome-scale metabolic reconstructions of each MAG.

## Metabolic reconstruction quality check (06_memote.sh)
Use Memote (https://memote.readthedocs.io/) to check stoichiometric consistency and other quality metrics of metabolic reconstructions.

## Collect Memote results (07_memote_results.sh)
Memote outputs HTML reports. This script collects the metrics into a text file.


