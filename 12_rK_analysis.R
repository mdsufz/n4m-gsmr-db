library(ggplot2)
library(ggtern)
library(data.table)
library(dplyr)
library(stringr)
library(viridisLite)
library(rcartocolor)


load("Y:\\Home\\magnusdo\\projects\\evoniche\\data\\combined.data.RData")

combined.data$quality <- "RefSeq"
combined.data$quality[(combined.data$completeness < 50) & (combined.data$contamination < 10)] <- "Low"
combined.data$quality[(combined.data$completeness >= 50) & (combined.data$contamination < 10)] <- "Medium"
combined.data$quality[(combined.data$completeness >= 90) & (combined.data$contamination < 5)] <- "High"
combined.data$quality <- factor(combined.data$quality, levels = c("Low", "Medium", "High", "RefSeq"))
combined.data$quality.score <- combined.data$completeness - 5*combined.data$contamination
combined.data$database <- "RefSeq"
combined.data$database[grepl("CTOTU", combined.data$mag)] <- "CLUE-TERRA"
combined.data$database[grepl("^[0-9]+", combined.data$mag)] <- "GEM"

# remove low quality from the data
combined.data <- subset(combined.data, (quality != "Low") & ((quality.score >= 50) | is.na(quality.score)))
combined.data <- subset(combined.data, database != "RefSeq")

# load the minimal media file (mag, max growth, max min media growth, #mets in min media)
model.minmedia <- fread("Y:\\Home\\magnusdo\\projects\\evoniche\\data\\model.growth.minmedia.csv", 
                        sep = ",", header = F)
model.minmedia <- as.data.frame(model.minmedia)
colnames(model.minmedia) <- c("mag", "max.growth", "max.growth.minmedia", "minmedia.n.mets")
model.minmedia$mag <- gsub(".xml", "", model.minmedia$mag)

# check how many MAGs per phylum of the ones that get data
minmedia.data <- merge(model.minmedia, combined.data, by = "mag")

minmedia.values <- fread("Y:\\Home\\magnusdo\\projects\\evoniche\\data\\minmedia.values.csv", 
                         sep = ",", header = T)
minmedia.values <- as.data.frame(minmedia.values)
rownames(minmedia.values) <- minmedia.values$V1
minmedia.values <- minmedia.values[, -c(1)]

minmedia.binary <- minmedia.values > 1e-6

# read in metabolite formulas
met.formulas <- read.csv("Y:\\Home\\magnusdo\\projects\\evoniche\\data\\met.formulas.csv", header = F)
mets <- data.frame(
  mets = colnames(minmedia.values),
  formulas = met.formulas$V2[match(colnames(minmedia.values), paste0("EX_", met.formulas$V1))]
)
mets$C <- as.numeric(str_extract(mets$formulas, "(?<=C)[0-9]+"))
mets$C[is.na(mets$C)] <- 0
mets$H <- as.numeric(str_extract(mets$formulas, "(?<=H)[0-9]+"))
mets$H[is.na(mets$H)] <- 0
mets$O <- as.numeric(str_extract(mets$formulas, "(?<=O)[0-9]+"))
mets$O[is.na(mets$O)] <- 0
mets$N <- as.numeric(str_extract(mets$formulas, "(?<=N)[0-9]+"))
mets$N[is.na(mets$N)] <- 0
mets$P <- as.numeric(str_extract(mets$formulas, "(?<=P)[0-9]+"))
mets$P[is.na(mets$P)] <- 0
mets$S <- as.numeric(str_extract(mets$formulas, "(?<=S)[0-9]+"))
mets$S[is.na(mets$S)] <- 0

# doesn't catch letters only (CH2) detects only H2, not C
for (i in 1:nrow(mets)) {
  if (grepl("C[A-Z]+", mets$formulas[i]) & (mets$C[i] == 0)) {
    mets$C[i] <- 1
  }
  if (grepl("H[A-Z]+", mets$formulas[i]) & (mets$H[i] == 0)) {
    mets$H[i] <- 1
  }
  if (grepl("O[A-Z]+", mets$formulas[i]) & (mets$O[i] == 0)) {
    mets$O[i] <- 1
  }
  if (grepl("N[A-Z]+", mets$formulas[i]) & (mets$N[i] == 0)) {
    mets$N[i] <- 1
  }
  if (grepl("P[A-Z]+", mets$formulas[i]) & (mets$P[i] == 0)) {
    mets$P[i] <- 1
  }
  if (grepl("S[A-Z]+", mets$formulas[i]) & (mets$S[i] == 0)) {
    mets$S[i] <- 1
  }
}

model.minmedia <- unique(model.minmedia)
model.minmedia$C.total <- rowSums(sweep(minmedia.values, MARGIN=2, mets$C, `*`))
model.minmedia$num.minmedia.C.mets <- rowSums(sweep(minmedia.binary, MARGIN=2, mets$C, `*`) > 0)
model.minmedia$minmedia.n.mets <- rowSums(minmedia.binary)
model.minmedia$growth.yield <- model.minmedia$max.growth.minmedia/(0.001 * model.minmedia$C.total)

# calculate the r/K indices
model.minmedia$rk.index <- log10(model.minmedia$growth.yield * model.minmedia$max.growth.minmedia * model.minmedia$num.minmedia.C.mets)

# calculate doubling time in minutes
model.minmedia$doubling.time.minmedia <- log(2)/log(1+model.minmedia$max.growth.minmedia)

# add genome quality information
model.minmedia$quality <- combined.data$quality[match(model.minmedia$mag, combined.data$mag)]


ggplot(model.minmedia, aes(x = rk.index)) +
  geom_histogram() +
  geom_vline(xintercept = mean(model.minmedia$rk.index), color = "red") +
  geom_vline(xintercept = mean(model.minmedia$rk.index) + 
               2 * sd(model.minmedia$rk.index), color = "green") +
  geom_vline(xintercept = mean(model.minmedia$rk.index) - 
               2 * sd(model.minmedia$rk.index), color = "green") +
  theme_bw() +
  theme(text = element_text(size = 16))

# check normality
shapiro.test(sample(model.minmedia$rk.index, 5000, replace = F))
# not normal

#Chesbyshev's Inequality
# 1-1/k^2
# 2 standard deviations include at least 75% of data
# 3 standard deviations include at least 89% of data
(2 * sd(model.minmedia$rk.index)) + mean(model.minmedia$rk.index)
#4.087979
#5th percentile
(-2 * sd(model.minmedia$rk.index)) + mean(model.minmedia$rk.index)
#-0.05352494



ggplot(model.minmedia, aes(x = rk.index)) +
  geom_histogram() +
  geom_vline(xintercept = mean(model.minmedia$rk.index), color = "red") +
  geom_vline(xintercept = (2 * sd(model.minmedia$rk.index)) + mean(model.minmedia$rk.index), 
             color = "green") +
  geom_vline(xintercept = (-2 * sd(model.minmedia$rk.index)) + mean(model.minmedia$rk.index), 
             color = "green") +
  theme_bw() +
  theme(text = element_text(size = 16))

# selecting the z-score cut-offs
cutoff.r <- subset(model.minmedia, rk.index < (-2 * sd(model.minmedia$rk.index)) + mean(model.minmedia$rk.index))
cutoff.k <- subset(model.minmedia, rk.index > (2 * sd(model.minmedia$rk.index)) + mean(model.minmedia$rk.index))


# full tern plot
ggtern(model.minmedia, 
       aes(x = max.growth.minmedia, 
           y = growth.yield, 
           z = num.minmedia.C.mets,
           color = rk.index)) +
  geom_point() +
  geom_point(size = 2, alpha =1) +
  #scale_color_viridis_c(option = "A", name = "r+K index") +
  scale_color_carto_c(name = "r+K index", palette = "Temps") +
  scale_L_continuous(name = "", labels = round(seq(from = 0, 
                                                   to = max(model.minmedia$max.growth.minmedia), 
                                                   by = max(model.minmedia$max.growth.minmedia)/5))) +
  scale_R_continuous(name = "", labels = round(seq(from = 0, 
                                                   to = max(model.minmedia$num.minmedia.C.mets), 
                                                   by = max(model.minmedia$num.minmedia.C.mets)/5))) +
  scale_T_continuous(name = "", labels = round(seq(from = 0, 
                                                   to = max(model.minmedia$growth.yield), 
                                                   by = max(model.minmedia$growth.yield)/5))) +
  theme_bw() +
  theme_showarrows()


# r/k mags only
ggtern(subset(model.minmedia, mag %in% union(cutoff.r$mag, cutoff.k$mag)), 
       aes(x = max.growth.minmedia, 
           y = growth.yield, 
           z = num.minmedia.C.mets,
           color = rk.index)) +
  geom_point() +
  geom_point(size = 2, alpha = 1) +
  scale_color_carto_c(name = "r+K index", palette = "Temps") +
  #scale_color_viridis_c(option = "A", name = "r+K index") +
  scale_L_continuous(name = "", labels = round(seq(from = 0, 
                                                   to = max(model.minmedia$max.growth.minmedia), 
                                                   by = max(model.minmedia$max.growth.minmedia)/5))) +
  scale_R_continuous(name = "", labels = round(seq(from = 0, 
                                                   to = max(model.minmedia$num.minmedia.C.mets), 
                                                   by = max(model.minmedia$num.minmedia.C.mets)/5))) +
  scale_T_continuous(name = "", labels = round(seq(from = 0, 
                                                   to = max(model.minmedia$growth.yield), 
                                                   by = max(model.minmedia$growth.yield)/5))) +
  theme_bw() +
  theme_showarrows()

# literature rk boxplots
# get the MAGs belonging to K-strategist taxa according to literature
k.strat <- unique(rbind(
  # https://www.nature.com/articles/s41598-021-03018-z
  subset(model.minmedia, mag %in% subset(minmedia.data, family == "Rhodobacteraceae")$mag),
  # https://www.sciencedirect.com/science/article/pii/S0048969722009287
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Nitrosospira")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Nitrospira")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Kuenenia")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, family == "Methanosaetaceae")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Methanolinea")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Methanosaeta")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Geobacter")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Sporolactobacillus")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Lactobacillus")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Pseudonocardia")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Rhodococcus")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Mycobacterium")$mag)
  # https://www.frontiersin.org/articles/10.3389/fmicb.2018.02730/full
  # above paper also had a list of r/K prevalent phyla/classes, but their data for the figure and text was unpublished.
  ))

r.strat <- unique(rbind(
  # https://www.nature.com/articles/s41598-021-03018-z
  subset(model.minmedia, mag %in% subset(minmedia.data, order == "Alteromonadales")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, order == "Vibrionales")$mag),
  # https://www.sciencedirect.com/science/article/pii/S0048969722009287
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Nitrosomonas")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Nitrosococcus")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Nitrobacter")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Nitrotoga")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Brocadia")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, family == "Methanosarcinaceae")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Methanobacterium")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Clostridium")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Acinetobacter")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, species == "Pseudomonas putida")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, species == "Methanosarcina concilii")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Thauera")$mag),
  subset(model.minmedia, mag %in% subset(minmedia.data, genus == "Mesotoga")$mag)
  # https://www.frontiersin.org/articles/10.3389/fmicb.2018.02730/full
  # above paper also had a list of r/K prevalent phyla/classes, but their data for the figure and text was unpublished.
  ))

# Mycobacterium frederiksbergense IN53 (K-strategist) and Acinetobacter sp. IN47 (r-strategist) also mentioned in paper, but our data does not contain such low-level differentiation

ggplot(model.minmedia) +
  geom_boxplot(data = subset(model.minmedia, mag %in% r.strat$mag), 
               aes(x = 1, y = rk.index), fill = "blue", alpha = 0.2) +
  #geom_jitter(data = subset(model.minmedia, mag %in% r.strat$mag), 
  #            aes(x = 1, y = rk.index, color = rk.index)) +
  geom_boxplot(data = subset(model.minmedia, mag %in% k.strat$mag), 
               aes(x = 2, y = rk.index), fill = "red", alpha = 0.2) +
  #geom_jitter(data = subset(model.minmedia, mag %in% k.strat$mag), 
  #            aes(x = 2, y = rk.index, color = rk.index)) +
  scale_x_continuous(breaks = c(1, 2), 
                     labels = c(
                       paste0("r-strategists (n=", nrow(r.strat), ")"), 
                       paste0("K-strategists (n=", nrow(k.strat), ")"))) +
  #scale_color_viridis_c(option = "A") +
  theme_bw() +
  theme(text = element_text(size = 16),
        axis.title.x = element_blank())

# difference between r-strategists and k-strategists
wilcox.test(subset(model.minmedia, mag %in% k.strat$mag)$rk.index,
            subset(model.minmedia, mag %in% r.strat$mag)$rk.index)
# W = 42803, p-value = 0.0002991

# save list of r and k mags
#fwrite(as.list(union(cutoff.k$mag, cutoff.r$mag)), 
#       file = "Y:\\Home\\magnusdo\\projects\\evoniche\\data\\rk.mag.list.txt",
#       sep = "\n")
