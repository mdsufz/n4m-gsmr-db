# === Pacotes ===
library(dplyr)
library(tidyr)
library(picante)
library(ape)
library(ggplot2)
library(openxlsx)

setwd("/home/anderson/Documents/Posdoc/GSMR Figures/rk NTI_NRI")
# === Caminhos ===
base_path <- "."
results_path <- file.path(base_path, "results")
dir.create(results_path, showWarnings = FALSE)

# === Funções ===

# 1. Gera matriz de abundância com base no nível taxonômico
generate_abundance_matrix <- function(df, tax_level = "GTDB.tk_phylum") {
  mat <- df %>%
    select(mag, all_of(tax_level)) %>%
    mutate(value = 1) %>%
    pivot_wider(names_from = mag, values_from = value, values_fill = 0) %>%
    as.data.frame()
  rownames(mat) <- mat[[tax_level]]
  mat[[tax_level]] <- NULL
  return(mat)
}

# 2. Calcula NTI e NRI para cada taxon
calculate_nri_nti <- function(abundance_matrix, tree) {
  dis <- cophenetic(tree)
  nri <- ses.mpd(as.matrix(abundance_matrix), dis, null.model = "taxa.labels", runs = 999)
  nti <- ses.mntd(as.matrix(abundance_matrix), dis, null.model = "taxa.labels", runs = 999)
  data.frame(
    Taxon = rownames(abundance_matrix),
    NRI_z = nri$mpd.obs.z,
    NRI_p = nri$mpd.obs.p,
    NRI_sd = nri$mpd.rand.sd,
    NTI_z = nti$mntd.obs.z,
    NTI_p = nti$mntd.obs.p,
    NTI_sd = nti$mntd.rand.sd
  )
}

# 3. Apenas marca quais taxons são significativos em NRI/NTI (sem Wilcoxon!)
test_nti_nri_diff <- function(df) {
  res <- df %>%
    filter(!is.na(NRI_z) & !is.na(NTI_z)) %>%
    mutate(
      Significant = ifelse(NRI_p < 0.05 | NTI_p < 0.05, "Yes", "No")
    )
  return(res)
}

# 4. Gráfico de barras para visualização dos resultados
plot_nri_nti <- function(df, title, filename) {
  df <- df %>%
    mutate(mean_z = (NRI_z + NTI_z) / 2) %>%
    arrange(mean_z)
  df$Taxon <- factor(df$Taxon, levels = df$Taxon)
  
  plot_data <- df %>%
    mutate(Significant = (NRI_p < 0.05 | NTI_p < 0.05)) %>%
    select(Taxon, NRI_z, NRI_sd, NRI_p, NTI_z, NTI_sd, NTI_p, Significant) %>%
    rename(NRI = NRI_z, NTI = NTI_z) %>%
    pivot_longer(cols = c("NRI", "NTI"), names_to = "Metric", values_to = "Z") %>%
    mutate(
      SD = ifelse(Metric == "NRI", NRI_sd, NTI_sd)
    ) %>%
    select(-NRI_sd, -NTI_sd, -NRI_p, -NTI_p)
  
  plot_data$Taxon <- factor(plot_data$Taxon, levels = levels(df$Taxon))
  
  p <- ggplot(plot_data, aes(x = Taxon, y = Z, fill = Metric)) +
    geom_bar(aes(color = Significant), stat = "identity", position = position_dodge(), width = 0.7) +
    geom_errorbar(aes(ymin = Z - SD, ymax = Z + SD), position = position_dodge(width = 0.7), width = 0.2) +
    geom_hline(yintercept = -1.96, linetype = "dashed", color = "red") +
    annotate("text", x = 0.5, y = -1.96, label = "Z = -1.96", vjust = -5, hjust = 0, size = 4.5, color = "red") +
    scale_color_manual(values = c("TRUE" = "black", "FALSE" = NA), guide = "none") +
    scale_fill_manual(values = c("NRI" = "#332288", "NTI" = "#DDCC77")) +
    coord_flip() +
    labs(title = title, x = "Taxon", y = "Z-score") +
    theme_minimal(base_size = 18) +
    theme(
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
      axis.title.x = element_text(size = 15, face = "bold"),
      axis.title.y = element_text(size = 15, face = "bold"),
      axis.text.x  = element_text(size = 12),
      axis.text.y  = element_text(size = 12),
      legend.title = element_text(size = 15, face = "bold"),
      legend.text  = element_text(size = 13),
      plot.title   = element_text(size = 21, face = "bold", hjust = 0.5)
    )
  
  ggsave(file.path(results_path, filename), p, width = 10, height = 6, device = "pdf")
}

# 5. Função principal: executa o fluxo completo e salva outputs
taxa_analysis <- function(domain, tax_level, tree_file, r_file, k_file) {
  message("== Analisando: ", domain, " | Taxon level: ", tax_level)
  
  r_data <- read.csv(r_file)
  k_data <- read.csv(k_file)
  tree <- read.tree(tree_file)
  
  for (strategy in c("r", "k")) {
    df <- if (strategy == "r") r_data else k_data
    mat <- generate_abundance_matrix(df, tax_level)
    mat <- mat[, colnames(mat) %in% tree$tip.label]
    
    results <- calculate_nri_nti(mat, tree)
    test_res <- test_nti_nri_diff(results)
    write.csv(test_res, file.path(results_path, paste0("nri_nti_", strategy, "_", domain, "_", tax_level, ".csv")), row.names = FALSE)
    
    # Monta o título no formato desejado
    strategy_label <- ifelse(strategy == "r", "r-strategist", "K-strategist")
    domain_label <- ifelse(domain == "archaea", "Archaea", "Bacteria")
    titulo <- paste(domain_label, strategy_label)
    
    plot_nri_nti(test_res, titulo, paste0(strategy, "_plot_", domain, "_", tax_level, ".pdf")) # PDF!
    
    # Tabela de significância individual
    signif_table <- test_res %>%
      mutate(
        Significance = case_when(
          NRI_p < 0.05 & NTI_p < 0.05 ~ "Both",
          NRI_p < 0.05 ~ "NRI",
          NTI_p < 0.05 ~ "NTI",
          TRUE ~ "None"
        )
      ) %>%
      select(Taxon, NRI_p, NTI_p, NRI_z, NTI_z, Significance)
    
    # Salva em CSV
    write.csv(signif_table, file.path(results_path, paste0("signif_summary_", strategy, "_", domain, "_", tax_level, ".csv")), row.names = FALSE)
    
    # Mostra os taxons com significância em algum
    signif_some <- signif_table %>% filter(Significance != "None")
    print(signif_some)
    
    # --- EXTRA: COMPARAÇÃO GLOBAL (Wilcoxon pareado para z-scores) ---
    cat("\n>>> Comparação global dos z-scores entre NTI e NRI (Wilcoxon pareado):\n")
    global_test <- wilcox.test(test_res$NTI_z, test_res$NRI_z, paired = TRUE)
    print(global_test)
    cat("Mediana NTI_z:", median(test_res$NTI_z, na.rm=TRUE), "| Mediana NRI_z:", median(test_res$NRI_z, na.rm=TRUE), "\n\n")
    
    # SALVAR RESULTADO DO WILCOXON EM CSV (acumulativo)
    wilcoxon_df <- data.frame(
      Domain = domain,
      Strategy = strategy,
      Tax_level = tax_level,
      N_taxa = nrow(test_res),
      W = global_test$statistic,
      p_value = global_test$p.value,
      median_NTI_z = median(test_res$NTI_z, na.rm=TRUE),
      median_NRI_z = median(test_res$NRI_z, na.rm=TRUE)
    )
    wilcoxon_path <- file.path(results_path, "wilcoxon_summary.csv")
    if (!file.exists(wilcoxon_path)) {
      write.table(wilcoxon_df, wilcoxon_path, sep = ",", row.names = FALSE, col.names = TRUE)
    } else {
      write.table(wilcoxon_df, wilcoxon_path, sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
    }
  }
}

# === Execução ===
taxa_analysis("archaea", "GTDB.tk_phylum",
              file.path(base_path, "gtdbtk.ar53.user.unrooted.tree"),
              file.path(base_path, "r_strategist_archaea.csv"),
              file.path(base_path, "k_strategist_archaea.csv"))

taxa_analysis("bacteria", "GTDB.tk_phylum",
              file.path(base_path, "gtdbtk.bac120.user.unrooted.tree_trimmed_tree_X_5158"),
              file.path(base_path, "r_strategist_bacteria.csv"),
              file.path(base_path, "k_strategist_bacteria.csv"))
