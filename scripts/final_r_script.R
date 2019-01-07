
# Set directory
setwd("/Users/prvasquez/Whiteheadlab/Projects/Mangrove_killifish/data") 

# Install dependancies

library("BiocInstaller", lib.loc="/Library/Frameworks/R.framework/Versions/3.5/Resources/library")

biocLite("limma")
biocLite("edgeR")
install.packages("ggplot2")
install.packages("gplots")
install.packages("dendextend")

library(limma)
library(edgeR)
library(ggplot2)
library(gplots)
library(dendextend)

# Design Matrix
sampleTable <- read.csv("design.matrixSRR08282018.csv", row.names = 1)
data.frame(sampleTable)
sampleTable_treatment <- subset(sampleTable, Air == "A" | Time == 0) # include time = 0 for the intercept group
data.frame(sampleTable_treatment)

# Setup read counts file
y <- read.table("~/Whiteheadlab/Projects/Mangrove_killifish/data/test2.out.txt", header = FALSE, sep = "\t", row.names = 1)
z <- scan("~/Whiteheadlab/Projects/Mangrove_killifish/data/test.names.txt", sep = '\t', what = "character")
colnames(y) <- z

# Subset data
y_treatment <- subset(y, select = c(row.names(sampleTable_treatment)))


# Filter data
y <- y[rowSums(y>10)>5, ]
y_treatment <- y_treatment[rowSums(y_treatment>10)>5, ] # ignore all read counts under 5 (or 10?)
data.frame(y_treatment)


# Create counts matrix for treatment group
dge_treatment <- DGEList(counts = y_treatment)
dge_treatment <- calcNormFactors(dge_treatment)
logcpm_treatment <- cpm(dge_treatment, prior.count = 2, log = TRUE)
dge_treatment$samples

# Design matrix for treatment
Time_treatment <- factor(sampleTable_treatment$Time, levels = c("0","1", "6", "24", "72", "164"))
Time_treatment <- relevel(Time_treatment, ref = "0")
Strain_treatment <- factor(sampleTable_treatment$Strain, levels = c("HON11", "FW"))
designmatrix_treatment <- model.matrix(~Time_treatment*Strain_treatment)
colnames(designmatrix_treatment)

# Fit voom for treatment
v_treatment <- voom(dge_treatment, designmatrix_treatment, plot = TRUE)
colnames(v_treatment)

# Lm fit for treatment
fit_treatment <- lmFit(v_treatment, designmatrix_treatment)
fit_treatment <- eBayes(fit_treatment)
summary(decideTests(fit_treatment))

# Diff expressed genes interactive
# Can adjust "number" to get top "X" genes
Dif_gene_treatment_all <- topTable(fit_treatment, coef = 8:12, adjust.method = "BH", number = Inf)
sum(Dif_gene_treatment_all$adj.P.Val<0.05) 
write.csv(Dif_gene_treatment_all, file = "/Users/prvasquez/Whiteheadlab/Projects/Mangrove_killifish/data/Dif_gene_treatment_all.csv", row.names = TRUE)
Dif_gene_treatment_all_names <- rownames(Dif_gene_treatment_all)


# Strain
Dif_gene_treatment_strain_all <- topTable(fit_treatment, coef = 7, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_treatment_strain_all, file = "/Users/prvasquez/Whiteheadlab/Projects/Mangrove_killifish/data/Dif_gene_treatment_strain_all.csv", row.names = TRUE)
Dif_gene_treatment_strain_names <- rownames(Dif_gene_treatment_strain)

# Time
Dif_gene_treatment_time_all <- topTable(fit_treatment, coef = 2:6, adjust.method = "BH", number = 20000)
write.csv(Dif_gene_treatment_time_all, file = "/Users/prvasquez/Whiteheadlab/Projects/Mangrove_killifish/data/Dif_gene_treatment_time_all.csv", row.names = TRUE)

