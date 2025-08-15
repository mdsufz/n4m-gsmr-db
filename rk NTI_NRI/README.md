# NTI/NRI Calculation per Taxon Using GTDB-Tk Phylogenetic Tree

This repository contains an R workflow for calculating **Net Relatedness Index (NRI)** and **Nearest Taxon Index (NTI)** for each taxon using a phylogenetic tree generated with **GTDB-Tk**. It produces per-taxon statistics, significance tests, and publication-ready bar plots.

---

## 1. Generating the Phylogenetic Tree with GTDB-Tk

This script requires a phylogenetic tree generated from your genome dataset using **GTDB-Tk**.

### Steps:

1. **Classify genomes**

   ```bash
   gtdbtk classify_wf \
     --genome_dir /path/to/genomes \
     --out_dir gtdbtk_out \
     --cpus 16
   ```

2. **Infer the phylogeny**

   * For bacteria:

     ```bash
     gtdbtk infer \
       --msa_file gtdbtk_out/align/gtdbtk.bac120.user_msa.fasta \
       --out_dir gtdbtk_out/tree_bac \
       --cpus 16
     ```
   * For archaea:

     ```bash
     gtdbtk infer \
       --msa_file gtdbtk_out/align/gtdbtk.ar53.user_msa.fasta \
       --out_dir gtdbtk_out/tree_archaea \
       --cpus 16
     ```

3. **Expected output files**:

   * `gtdbtk.bac120.user.unrooted.tree`
   * `gtdbtk.ar53.user.unrooted.tree`

These files are later provided to the R script.

---

## 2. Required Input Files for the R Script

For each domain (Bacteria and Archaea), you need:

* **Phylogenetic tree file** (`.tree`, Newick format)
* **Two CSV files** listing MAGs per ecological strategy:

  * `r_strategist_bacteria.csv`
  * `k_strategist_bacteria.csv`
  * `r_strategist_archaea.csv`
  * `k_strategist_archaea.csv`

Each CSV must contain at least:

* `mag` → genome identifier (must match the tree tip labels)
* `GTDB.tk_phylum` (or other taxonomic level used in the analysis)

---

## 3. Installing Dependencies in R

```r
install.packages(c("dplyr", "tidyr", "ggplot2", "ape", "openxlsx"))
# Install picante from CRAN or BioConductor depending on your setup
install.packages("picante")
```

**Packages used:**

* `dplyr`, `tidyr`: data manipulation
* `picante`: computation of NRI (ses.mpd) and NTI (ses.mntd)
* `ape`: phylogenetic tree handling
* `ggplot2`: data visualization
* `openxlsx`: optional Excel output

---

## 4. How the Script Works

### Functions

1. **`generate_abundance_matrix(df, tax_level)`**

   * Creates a presence/absence matrix for taxa (rows) vs. MAGs (columns).

2. **`calculate_nri_nti(abundance_matrix, tree)`**

   * Computes phylogenetic distances with `cophenetic(tree)`.
   * Calculates:

     * NRI Z-scores, p-values, and randomization SDs via `ses.mpd`
     * NTI Z-scores, p-values, and randomization SDs via `ses.mntd`

3. **`test_nti_nri_diff(df)`**

   * Flags taxa as significant if **either** NRI\_p < 0.05 **or** NTI\_p < 0.05.

4. **`plot_nri_nti(df, title, filename)`**

   * Produces bar plots for NRI and NTI Z-scores per taxon.
   * Highlights significant taxa.
   * Adds a reference line at Z = -1.96.

5. **`taxa_analysis(domain, tax_level, tree_file, r_file, k_file)`**

   * Reads domain-specific tree and CSV files.
   * Generates abundance matrix, calculates NRI/NTI, and runs significance test.
   * Saves CSV summaries and PDF plots in the `results/` folder.
   * Performs a paired Wilcoxon test between NTI\_z and NRI\_z.

---

## 5. Running the Script

Example execution:

```r
# Archaea
taxa_analysis(
  domain = "archaea",
  tax_level = "GTDB.tk_phylum",
  tree_file = file.path(base_path, "gtdbtk.ar53.user.unrooted.tree"),
  r_file = file.path(base_path, "r_strategist_archaea.csv"),
  k_file = file.path(base_path, "k_strategist_archaea.csv")
)

# Bacteria
taxa_analysis(
  domain = "bacteria",
  tax_level = "GTDB.tk_phylum",
  tree_file = file.path(base_path, "gtdbtk.bac120.user.unrooted.tree_trimmed_tree_X_5158"),
  r_file = file.path(base_path, "r_strategist_bacteria.csv"),
  k_file = file.path(base_path, "k_strategist_bacteria.csv")
)
```

All output files are saved in the `results/` directory:

* `nri_nti_*` → raw NRI/NTI results
* `signif_summary_*` → per-taxon significance summary
* `*_plot_*` → PDF bar plots
* `wilcoxon_summary.csv` → global Wilcoxon test results
