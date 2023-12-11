# a script to collect the results of interest from a set of Memote HTML reports

#!/bin/bash

# report directory
RDIR="/work/magnusdo/evoniche/memote_reports"

# mag report
MAGR="$1"

# stoichiometric consistency
stoich_consist=$(grep -Po "(?<=consistent\"\,\"data\"\:)([a-z]{4,5})(?=\,)" "$RDIR"/"$MAGR")

# scores
total_score=$(grep -Po '(?<=total_score\"\:)(\d.\d+)' "$RDIR"/"$MAGR")
consistency_score=$(grep -Po '(?<=\"section\"\:\"consistency\"\,\"score\"\:)(\d.\d+)' "$RDIR"/"$MAGR")
ann_rxn_score=$(grep -Po '(?<=\"section\"\:\"annotation\_rxn\"\,\"score\"\:)(\d.\d+)' "$RDIR"/"$MAGR")
ann_met_score=$(grep -Po '(?<=\"section\"\:\"annotation\_met\"\,\"score\"\:)(\d.\d+)' "$RDIR"/"$MAGR")
ann_gene_score=$(grep -Po '(?<=\"section\"\:\"annotation\_gene\"\,\"score\"\:)(\d.\d+)' "$RDIR"/"$MAGR")
ann_sbo_score=$(grep -Po '(?<=\"section\"\:\"annotation\_sbo\"\,\"score\"\:)(\d.\d+)' "$RDIR"/"$MAGR")

# mets
mets_num=$(grep -Po '\d+(?= metabolites are defined in the model)' "$RDIR"/"$MAGR")

# rxns
rxns_num=$(grep -Po '\d+(?= reactions are defined in the model)' "$RDIR"/"$MAGR")

# genes
genes_num=$(grep -Po '\d+(?= genes are defined in the model)' "$RDIR"/"$MAGR")

# compartments
compartments_num=$(grep -Po '\d+(?= compartments are defined in the model)' "$RDIR"/"$MAGR")

# metabolic coverage
mets_coverage=$(grep -Po '(?<=The degree of metabolic coverage is )\d+.\d+' "$RDIR"/"$MAGR")

# unconserved metabolites
mets_unconserved=$(grep -Po '(?<=This model contains )\d+(?= unconserved metabolites)' "$RDIR"/"$MAGR")

# metabolites without charge
mets_nocharge=$(grep -Po '(?<=There are a total of )\d+(?= +metabolites[0-9a-zA-Z\\ \%\(\).]{1,50}charge)' "$RDIR"/"$MAGR")

# metabolites without formula
mets_noformula=$(grep -Po '(?<=There are a total of )\d+(?= +metabolites[0-9a-zA-Z\\ \%\(\).]{1,50}formula)' "$RDIR"/"$MAGR")

# reactions without GPR
rxns_nogpr=$(grep -Po '(?<=There are a total of )\d+(?= +reactions[0-9a-zA-Z\\ \%\(\).]{1,50}GPR)' "$RDIR"/"$MAGR")

# purely metabolic reactions
rxns_metabolic=$(grep -Po '(?<=A total of )\d+(?=[0-9a-zA-Z\\ \%\(\).]{1,50}purely metabolic reactions are)' "$RDIR"/"$MAGR")

# transport reactions
rxns_transport=$(grep -Po '(?<=A total of )\d+(?=[0-9a-zA-Z\\ \%\(\).]{1,50}transport reactions are)' "$RDIR"/"$MAGR")

# charge unbalanced reactions
rxns_chargeunbalanced=$(grep -Po '(?<=A total of )\d+(?=[0-9a-zA-Z\\ \%\(\).]{1,50}reactions are charge unbalanced)' "$RDIR"/"$MAGR")

# mass unbalanced reactions
rxns_massunbalanced=$(grep -Po '(?<=A total of )\d+(?=[0-9a-zA-Z\\ \%\(\).]{1,50}reactions are mass unbalanced)' "$RDIR"/"$MAGR")

# blocked reactions
rxns_blocked=$(grep -Po '(?<=There are )\d+(?=[0-9a-zA-Z\\ \%\(\).]{1,50}blocked reactions)' "$RDIR"/"$MAGR")

# stoichiometrically balanced cycles
sbc=$(grep -Po '(?<=There are )\d+(?=[0-9a-zA-Z\\ \%\(\).]{1,50}SBC)' "$RDIR"/"$MAGR")

# rank
rank=$(grep -Po '(?<=The rank of the S-Matrix is )\d+' "$RDIR"/"$MAGR")

# degrees of freedom
degfree=$(grep -Po '(?<=The degrees of freedom of the S-Matrix are )\d+' "$RDIR"/"$MAGR")

# independent conservation relations
conservation=$(grep -Po '(?<=The number of independent conservation relations is )\d+' "$RDIR"/"$MAGR")

# set everything up in a row and append to file
echo "${MAGR/.html/}\t$stoich_consist\t$total_score\$consistency_score\t$ann_rxn_score\t$ann_met_score\t$ann_gene_score\t$ann_sbo_score\t$mets_num\t$rxns_num\t$genes_num\t$compartments_num\t$mets_coverage\t$mets_unconserved\t$mets_nocharge\t$mets_noformula\t$rxns_nogpr\t$rxns_metabolic\t$rxns_transport\t$rxns_chargeunbalanced\t$rxns_massunbalanced\t$rxns_blocked\t$sbc\t$rank\t$degfree\t$conservation" >> /work/magnusdo/evoniche/evoniche_memote_summary.tsv

