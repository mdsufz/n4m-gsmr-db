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

## Taxonomic classification (08_gtdbtk.sh)
Using GTDB-tk (https://github.com/Ecogenomics/GTDBTk) to predict the taxonomic classification of the MAGs.

## Simulate metabolic model minimal media and growth on minimal media (09_minimal_media.py)
Use COBRApy (https://github.com/opencobra/cobrapy) to simulate the minimal media using the built-in function.

## Getting a unique list of all minimal media metabolites (10_minimal_media_components.sh)

## Minimal media per model (11_minimal_media_values.R)
Create two matrices: one containing the presence/absence of each metabolite in the minimal media of each model, and the second containing the same information but with the simulated flux values instead of the binary data.
