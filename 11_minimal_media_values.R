#module load GCC/8.3.0 OpenMPI/3.1.4 R/4.0.0
#R

library(data.table)

components <- read.csv("/work/magnusdo/evoniche/minmedia.components.csv", header = FALSE, sep = ",")
files <- list.files(path = "/work/magnusdo/evoniche/minmedia", pattern = "*.csv", full.names = FALSE, recursive = FALSE)

minmedia.binary <- matrix(0, nrow = length(files), ncol = length(components$V1))
minmedia.values <- matrix(0, nrow = length(files), ncol = length(components$V1))

for (file in files) {
	minmedia.model <- read.csv(paste0("/work/magnusdo/evoniche/minmedia/", file), header = FALSE, sep = ",")
	minmedia.binary[which(files == file), match(minmedia.model$V1, components$V1)] <- 1
	minmedia.values[which(files == file), match(minmedia.model$V1, components$V1)] <- minmedia.model$V2
}

minmedia.values <- as.data.frame(minmedia.values)
minmedia.binary <- as.data.frame(minmedia.binary)

rownames(minmedia.binary) <- gsub(".xml.csv", "", files)
rownames(minmedia.values) <- gsub(".xml.csv", "", files)
colnames(minmedia.binary) <- components$V1
colnames(minmedia.values) <- components$V1

fwrite(minmedia.binary, file = "/work/magnusdo/evoniche/minmedia.binary.csv", quote = F, sep = ",", row.names = T, col.names = T)
fwrite(minmedia.values, file = "/work/magnusdo/evoniche/minmedia.values.csv", quote = F, sep = ",", row.names = T, col.names = T)
  
