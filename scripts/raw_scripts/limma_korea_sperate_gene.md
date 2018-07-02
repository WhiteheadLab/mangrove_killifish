# Limma with Seperate Counts

## R script

Install and load packages
```
install.packages("limma")
install.packages("edgeR")
install.packages("ggplot2")
install.packages("gplots")
install.packages("dendextend")
install.packages("splines")

library(limma)
library(edgeR)
library(ggplot2)
library(gplots)
library(dendextend)
library(splines)
```

Set Working Directory
```
setwd("D:/mangrove_killifish_project/limma/limma_with_seperate_counts/Data")
```

### 1. Design matrix input
```
(sampleTable_control <- read.csv("design.matrix_control.csv", row.names = 1))
sampleTable_control <- sampleTable_control[-c(12), ] # No 484
data.frame(sampleTable_control)

(sampleTable_treated <- read.csv("design.matrix_treated.csv", row.names = 1))
sampleTable_treated <- sampleTable_treated[-c(58), ] # No 484
sampleTable_treated <- sampleTable_treated[-c(22), ] # No 919
data.frame(sampleTable_treated)

(sampleTable <- read.csv("design.matrix01262017.csv", row.names = 1 ))
sampleTable <- sampleTable[-c(33), ] # No 484
sampleTable <- sampleTable[-c(75), ] # No 919
data.frame(sampleTable)
```

### 2. Read counts file

#### 2.1 Set data
```
x <- read.csv("all_counts_table_gene.csv", head = TRUE)
rownames(x) = x[, 1] # set row name
x <- subset(x, select = -X) # subsetting data
x <- subset(x, select = -X484_quant) # No 484
x <- subset(x, select = -X919_quant) # No 919
```

#### 2.2 Susetting data for control
```
x_control <- subset(x, select = c(X134_quant, X139_quant, X144_quant, 
                               X149_quant, X224_quant, X229_quant, 
                               X234_quant, X239_quant, X364_quant, 
                               X369_quant, X374_quant, X489_quant, 
                               X494_quant, X499_quant, X559_quant, 
                               X564_quant, X569_quant, X574_quant, 
                               X619_quant, X624_quant, X629_quant, 
                               X634_quant, X739_quant, X849_quant, 
                               X859_quant, X874_quant, X914_quant, 
                               X959_quant, X964_quant))
```

#### 2.3 Susetting data for treatment in air
```
x_treatment <- subset(x, select = c(X004_quant, X009_quant, X014_quant, 
                                 X019_quant, X214_quant, X264_quant, 
                                 X269_quant, X274_quant, X279_quant, 
                                 X304_quant, X309_quant, X314_quant, 
                                 X319_quant, X324_quant, X329_quant, 
                                 X334_quant, X339_quant, X464_quant, 
                                 X469_quant, X474_quant, X479_quant, 
                                 X489_quant, X494_quant, 
                                 X499_quant, X504_quant, X509_quant, 
                                 X514_quant, X519_quant, X524_quant, 
                                 X529_quant, X534_quant, X559_quant, 
                                 X564_quant, X569_quant, X574_quant, 
                                 X579_quant, X584_quant, X589_quant, 
                                 X594_quant, X599_quant, X604_quant, 
                                 X609_quant, X614_quant, X639_quant, 
                                 X644_quant, X649_quant, X684_quant, 
                                 X704_quant, X719_quant, X739_quant, 
                                 X784_quant, X804_quant, X809_quant, 
                                 X819_quant, X849_quant, X879_quant, 
                                 X929_quant, X934_quant))
```

#### 2.4 Get rid of x in colnames
```
colnames(x) <- gsub("X", "", colnames(x))
colnames(x_control) <- gsub("X", "", colnames(x_control))
colnames(x_treatment) <- gsub("X", "", colnames(x_treatment))
```

#### 2.5 Data filter
```
x <- x[rowSums(x>10)>5, ]
x_control <- x_control[rowSums(x_control>10)>5, ]
x_treatment <- x_treatment[rowSums(x_treatment>10)>5, ]
data.frame(x_control)
data.frame(x_treatment)
dge_all <- DGEList(counts = x)
```

### 3. Data analysis for control samples

#### 3.1 Counts matrix
```
dge_control <- DGEList(counts = x_control)
dge_control <- calcNormFactors(dge_control)
logCPM_contorl <- cpm(dge_control, prior.count = 2, log = TRUE)
```

#### 3.2 PCA plotting for Control
```
dge_control$samples
MDS_dge_control <- plotMDS(dge_control, gene.selection = "common", main = "MDS_control_dge")
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_control_with_ID_dge.png")
dev.off()
MDS_logCPM_control <- plotMDS(logcpm_contorl, gene.selection = "common", main = "MDS_control_logcpm")
dev.copy(pdf, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_control_with_ID_logcpm.pdf")
dev.off()
MDS_logCPM_control <- cbind(sampleTable_control, MDS_logCPM_control$cmdscale.out)
write.csv(MDS_logCPM_control, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_logCPM_control_PCA.csv")
    
# PCA with symbols
strain_C <- sampleTable_control$Strain
col.fill <- c("blue", "yellow", "red")
shape <- c(22, 24)
plotMDS(logCPM_contorl, pch = shape[as.factor(sampleTable_control$Strain)], 
        bg = col.fill[as.factor(sampleTable_control$Time)], cex = 1.5, lwd = 3, 
        gene.selection = "common", plot = TRUE, main = "MDS_control_logCPM")
legend("topleft", legend = c("0d", "3d", "7d"), col = col.fill, pch = 15)
legend("topright", legend = c("FW", "HON11"), pch = shape)
dev.copy(pdf, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_control_with_symbol_dge.pdf")
dev.off()
```

#### 3.3 ```deisgn.matrix``` for control
```
Time_control <- factor(sampleTable_control$Time, levels = c( "0", "72", "164"))
Time_control <- relevel(Time_control, ref = "0") 
Strain_control <- factor(sampleTable_control$Strain, levels = c("HON11", "FW"))
designmatrx_control <- model.matrix(~Time_control*Strain_control)
colnames(designmatrx_control)
```

#### 3.4 Fit ```voom``` with design_control
```
v_control <- voom(dge_control, designmatrx_control, plot = TRUE)
colnames(v_control)
```

#### 3.5 ```lmFit``` for control
```
fit_control <- lmFit(v_control, designmatrx_control)
fit_control <- eBayes(fit_control)
summary(decideTests(fit_control))
Dif_gene_control <- topTable(fit_control, coef = 5:6, adjust.method = "BH")
sum(Dif_gene_control$adj.P.Val<0.05)
```

#### 3.6 ```vocanoplot``` for control 
```
volcanoplot(fit_control, coef = 5:6, main = "Control_two_strain")
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Volcano_control_dge.png")
dev.off()
```

### 4. Data analysis for treated samples in air

#### 4.1 Counts matrix
```
dge_treatment <- DGEList(counts = x_treatment)
dge_treatment <- calcNormFactors(dge_treatment)
logcpm_treatment <- cpm(dge_treatment, prior.count = 2, log = TRUE)
dge_treatment$samples
write.csv(logcpm_treatment, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/Data/logcpm_treatment_filted.csv")
```

#### 4.2 PCA plotting for treatment
```
plotMDS(dge_treatment, gene.selection = "common", main = "MDS_air_dge")
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_air_dge_with_ID.png")
dev.off()

strain_T <- sampleTable_treated$Strain
col.fill <- c("blue", "skyblue", "yellow", "pink", "red", "black")
shape <- c(22, 24)
MDS_logCPM_treat <- plotMDS(logcpm_treatment, pch = shape[as.factor(sampleTable_treated$Strain)], 
        bg = col.fill[as.factor(sampleTable_treated$Time)], cex = 1.5, lwd = 3, 
        gene.selection = "common", plot = TRUE, main = "MDS_air_logCPM")
legend("topleft", legend = c("0d", "1h", "6h", "1d", "3d", "7d"), col = col.fill, pch = 15)
legend("topright", legend = c("FW", "HON11"), pch = shape)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_air_logCPM_with_symbol.png")
dev.off()
MDS_logCPM_treat <- cbind(sampleTable_treated, MDS_logCPM_treat$cmdscale.out)
write.csv(MDS_logCPM_treat, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_logCPM_treat_PCA.csv")
```

#### 4.3 ```deisgn.matrix``` for treatment
```
Time_treatment <- factor(sampleTable_treated$Time, levels = c( "0", "1", "6", "24", "72", "164"))
Time_treatment <- relevel(Time_treatment, ref = "0") 
Strain_treatment <- factor(sampleTable_treated$Strain, levels = c("HON11", "FW"))
designmatrx_treatment <- model.matrix(~Time_treatment*Strain_treatment)
colnames(designmatrx_treatment)
```

#### 4.4 Fit ```voom``` with design_treatment
```
v_treatment <- voom(dge_treatment, designmatrx_treatment, plot = TRUE)
colnames(v_treatment)
```

#### 4.5 ```lmFit``` for treatment in air
```
fit_treatment <- lmFit(v_treatment, designmatrx_treatment)
fit_treatment <- eBayes(fit_treatment)
summary(decideTests(fit_treatment))
```

#### 4.6 Different expressed genes interactive
``` 
# Dif_gene_treatment_50 <- topTable(fit_treatment, coef = 8:12, adjust.method = "BH", number = 50, p.value = 0.05)
# sum(Dif_gene_treatment_50$adj.P.Val<0.05)
# write.csv(Dif_gene_treatment_50, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_treatmentTOP50.csv", row.names = TRUE)
# Dif_gene_treatment_50_names <- rownames(Dif_gene_treatment_50)

Dif_gene_treatment_all <- topTable(fit_treatment, coef = 8:12, adjust.method = "BH", number = Inf, p.value = 0.05)
sum(Dif_gene_treatment_all$adj.P.Val<0.05) # all differential expressed genes
write.csv(Dif_gene_treatment_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_treatment_all.csv", row.names = TRUE)
Dif_gene_treatment_all_names <- rownames(Dif_gene_treatment_all)

Dif_gene_treatment_listall <- topTable(fit_treatment, coef = 8:12, adjust.method = "BH", number = Inf) # all genes with P.values
write.csv(Dif_gene_treatment_listall, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_treatment_interaction_listall.csv", row.names = TRUE)

strain_T <- sampleTable_treated$Strain
col.fill <- c("blue", "skyblue", "yellow", "pink", "red", "black")
shape <- c(22, 24)
MDS_logCPM_treat_interaction_genes <- plotMDS(logcpm_treatment[Dif_gene_treatment_all_names, ], pch = shape[as.factor(sampleTable_treated$Strain)], 
                          bg = col.fill[as.factor(sampleTable_treated$Time)], cex = 1.5, lwd = 3, 
                          gene.selection = "common", plot = TRUE, main = "MDS_air_logCPM_interaction_genes")
legend("topleft", legend = c("0d", "1h", "6h", "1d", "3d", "7d"), col = col.fill, pch = 15)
legend("topright", legend = c("FW", "HON11"), pch = shape)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_air_logCPM_with_symbol_interaction_gene.png")
dev.off()
MDS_logCPM_treat <- cbind(sampleTable_treated, MDS_logCPM_treat_interaction_genes$cmdscale.out)
write.csv(MDS_logCPM_treat, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_logCPM_treat_interaction_genes_PCA.csv")

# threshold <- as.logical(Dif_gene_treatment$adj.P.Val<0.01)
# Dif_gene_treatment_2 <- cbind(threshold, Dif_gene_treatment) 
# Dif_gene_treatment_2 <- rownames(dge_treatment$counts)[which(Dif_gene_treatment_2$threshold)]
# length(Dif_gene_treatment_2)
```

#### 4.7 Heatmap for treatment in air
  
##### 4.7.1 Prepare re-ordered sampleTable
```
sampleTable_treated.2 <- sampleTable_treated[order(sampleTable_treated$Strain, sampleTable_treated$Time), ]
```

##### 4.7.2 Prepare the ```logcpm_treat_normalized``` data file
```
logcpm_treat_normalized <- read.csv("D:/mangrove_killifish_project/limma/limma_with_seperate_counts/Data/logcpm_treatment_for_strain_heatmap.csv", head = TRUE, row.names = 1)
colnames(logcpm_treat_normalized) <- gsub("X", "", colnames(logcpm_treat_normalized))
# View(logcpm_treat_normalized)
# my_data_50 <- logcpm_treat_normalized[Dif_gene_treatment_50_names, ]
my_data_all <- logcpm_treat_normalized[Dif_gene_treatment_all_names, ]
# my_data <- log2(my_data+1)
# my_data_50 <- my_data_50[, row.names(sampleTable_treated.2)]
my_data_all <- my_data_all[, row.names(sampleTable_treated.2)]
# 4.7.3 Draw a heatmap for air using top50 genes and all genes
library(ComplexHeatmap)
library(circlize)
# data.frame(my_data)
# dim(my_data)
# nrow(my_data) # Genes
# ncol(my_data) # samplesd
# make the heatmap data into a matrix
# my_matrix_50 <- as.matrix(my_data_50[, c(1:58)])
my_matrix_all <- as.matrix(my_data_all[, c(1:58)])
# class(my_data)
# class(my_matrix)
# Default parameter Heatmap
fontsize <- 0.6
dend_diff_Top50 = hclust(dist(my_matrix_50, method = "maximum"), method = "ward.D")
df <- data.frame(sampleTable_treated.2)
ha <- HeatmapAnnotation(df = df, col = list(
  Strain = c("HON11" = "lightgreen", "FW" = "lightgray"), 
# Time = colorRamp2(c(0, 165), c("white", "red"))
  Time = c("0" = "purple", "1" = "blue", "6" = "green", "24" = "yellow", "72" = "orange", "164" = "red")))
# draw(ha, 1:58)
Heatmap(my_matrix_50, cluster_columns = FALSE, # using top50 genes
        show_row_names = TRUE, 
        show_column_names = FALSE, 
        row_names_side = "left", 
        row_dend_side = "left", 
        row_names_gp = gpar(cex = fontsize), 
        row_dend_width = unit(2, "cm"), 
        clustering_distance_rows = "maximum", 
        clustering_method_rows = "ward.D", 
        cluster_rows = color_branches(dend_diff_Top50, k = 4), 
        bottom_annotation = ha)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Heatmap_interaction_TOP50.png")
dev.off()

dend_diff_all = hclust(dist(my_matrix_all, method = "maximum"), method = "ward.D")
Heatmap(my_matrix_all, cluster_columns = FALSE, # using all interaction genes
        show_row_names = FALSE, 
        show_column_names = FALSE, 
        row_names_side = "left", 
        row_dend_side = "left", 
        row_names_gp = gpar(cex = fontsize), 
        row_dend_width = unit(2, "cm"), 
        clustering_distance_rows = "maximum", 
        clustering_method_rows = "ward.D", 
        cluster_rows = color_branches(dend_diff_all, k = 5), 
        bottom_annotation = ha)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Heatmap_interaction_all.png")
dev.off()
```

#### 4.8 Volcano for air
```
volcanoplot(fit_treatment, coef = 8:12, main = "Treatment_two_strain")
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/volcano_treatment_two_strains.png")
dev.off()

# rpkm(txi$counts, txi$length)
```

### 5. Different expressed genes between strains

#### 5.1 Differential expressed genes between strains
```
Dif_gene_strain_top300 <- topTable(fit_treatment, coef = 7, adjust.method = "BH", number = 1000, p.value = 0.05)
sum(Dif_gene_strain_top300$adj.P.Val<0.05)
write.csv(Dif_gene_strain_top300, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_strain_441.csv")
Dif_gene_strain_all <- topTable(fit_treatment, coef = 7, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_strain_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_strain_all.csv")

strain_T <- sampleTable_treated$Strain
col.fill <- c("blue", "skyblue", "yellow", "pink", "red", "black")
shape <- c(22, 24)
MDS_logCPM_treat_strain_genes <- plotMDS(logcpm_treatment[rownames(Dif_gene_strain_top300), ], pch = shape[as.factor(sampleTable_treated$Strain)], 
                                            bg = col.fill[as.factor(sampleTable_treated$Time)], cex = 1.5, lwd = 3, 
                                            gene.selection = "common", plot = TRUE, main = "MDS_air_logCPM_strain_genes")
legend("topleft", legend = c("0d", "1h", "6h", "1d", "3d", "7d"), col = col.fill, pch = 15)
legend("topright", legend = c("FW", "HON11"), pch = shape)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_air_logCPM_with_symbol_strain_gene.png")
dev.off()
MDS_logCPM_treat <- cbind(sampleTable_treated, MDS_logCPM_treat_strain_genes$cmdscale.out)
write.csv(MDS_logCPM_treat, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_logCPM_treat_strain_genes_PCA.csv")
```
 
#### 5.2 Heatmap for treatment between strains

##### 5.2.1 Data of all differential expressed gene between strains
```
sampleTable_treated.2 <- sampleTable_treated[order(sampleTable_treated$Strain, sampleTable_treated$Time), ] # prepare re-ordered sampleTable
logCPM_treat_strain_normalized <- read.csv("D:/mangrove_killifish_project/limma/limma_with_seperate_counts/Data/logcpm_treatment_for_strain_heatmap.csv", row.names = 1)
colnames(logCPM_treat_strain_normalized) <- gsub("X", "", colnames(logCPM_treat_strain_normalized))
my_data_strain <- logCPM_treat_strain_normalized[rownames(Dif_gene_strain_top300), ]
 # my_data <- log2(my_data+1)
my_data_strain <- my_data_strain[, row.names(sampleTable_treated.2)]
```

##### 5.2.2 Draw a heatmap between strain
```
my_matrix_strain <- as.matrix(my_data_strain[, c(1:58)]) # make the heatmap data into a matrix
dend_strain = hclust(dist(my_matrix_strain, method = "maximum"), method = "ward.D")
Heatmap(my_matrix_strain, cluster_columns = FALSE, 
        show_row_names = FALSE, 
        show_column_names = FALSE, 
        row_names_side = "left", 
        row_dend_side = "left", 
        row_names_gp = gpar(cex = fontsize), 
        row_dend_width = unit(2, "cm"), 
        clustering_distance_rows = "maximum", 
        clustering_method_rows = "ward.D", 
        cluster_rows = color_branches(dend_strain, k = 5), 
        bottom_annotation = ha)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Heatmap_strain.png")
dev.off()
```

##### 5.2.3 Data of all differential expressed gene between strains without interactive genes
```
# my_data_strain_rownames <- rownames(my_data_strain)
# write.csv(my_data_strain_rownames, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/my_data_strain_rownames.csv")
# write.csv(Dif_gene_treatment_all_names, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_treatment_all_names.csv")
# my_data_strain_rownames <- read.csv("D:/mangrove_killifish_project/limma/limma_with_seperate_counts/Data/my_data_strain_rownames.csv", header = FALSE)
# my_data_strain_rownames <- as.character(my_data_strain_rownames$V1)
my_data_strain_no_interaction_rownames <- my_data_strain_rownames[!my_data_strain_rownames%in%Dif_gene_treatment_all_names]
my_data_strain_no_interaction <- logCPM_treat_strain_normalized[my_data_strain_no_interaction_rownames, ]
my_data_strain_no_interaction <- my_data_strain_no_interaction[, row.names(sampleTable_treated.2)]
my_matrix_strain_no_interaction <- as.matrix(my_data_strain_no_interaction[, c(1:58)]) # make the heatmap data into a matrix
class(my_data_strain_no_interaction)
class(my_matrix_strain_no_interaction)
# Default parameter Heatmap
dend_no_interaction = hclust(dist(my_matrix_strain_no_interaction, method = "maximum"), method = "ward.D")
Heatmap(my_matrix_strain_no_interaction, cluster_columns = FALSE, 
        show_row_names = FALSE, 
        show_column_names = FALSE, 
        row_names_side = "left", 
        row_dend_side = "left", 
        row_names_gp = gpar(cex = fontsize), 
        row_dend_width = unit(2, "cm"), 
        clustering_distance_rows = "maximum", 
        clustering_method_rows = "ward.D", 
        cluster_rows = color_branches(dend_no_interaction, k = 4), 
        bottom_annotation = ha)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Heatmap_strain_no_interaction.png")
dev.off()

strain_T <- sampleTable_treated$Strain
col.fill <- c("blue", "skyblue", "yellow", "pink", "red", "black")
shape <- c(22, 24)
MDS_logCPM_treat_strain_no_interaction_genes <- plotMDS(logcpm_treatment[my_data_strain_no_interaction_rownames, ], pch = shape[as.factor(sampleTable_treated$Strain)], 
                                       bg = col.fill[as.factor(sampleTable_treated$Time)], cex = 1.5, lwd = 3, 
                                       gene.selection = "common", plot = TRUE, main = "MDS_air_logCPM_strain_no_interaction_genes")
legend("topleft", legend = c("0d", "1h", "6h", "1d", "3d", "7d"), col = col.fill, pch = 15)
legend("topright", legend = c("FW", "HON11"), pch = shape)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_air_logCPM_with_symbol_strain_no_interaction_gene.png")
dev.off()
MDS_logCPM_treat_strain_no_interaction_genes <- cbind(sampleTable_treated, MDS_logCPM_treat_strain_genes$cmdscale.out)
write.csv(MDS_logCPM_treat_strain_no_interaction_genes, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_logCPM_treat_strain_no_interaction_genes_PCA.csv")
```

### 6. Heatmap with different expressed genes between time points

#### 6.1 Differential expressed genes among different time points
```
Dif_gene_time_top4000 <- topTable(fit_treatment, coef = 2:6, adjust.method = "BH", number = 10000, p.value = 0.05)
sum(Dif_gene_time_top4000$adj.P.Val<0.05)
write.csv(Dif_gene_time_top4000, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_time_top4000.csv", row.names = TRUE)

Dif_gene_time_all <- topTable(fit_treatment, coef = 2:6, adjust.method = "BH", number = 20000)
sum(Dif_gene_time_all$adj.P.Val<0.05)
write.csv(Dif_gene_time_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_time_all.csv", row.names = TRUE)

strain_T <- sampleTable_treated$Strain
col.fill <- c("blue", "skyblue", "yellow", "pink", "red", "black")
shape <- c(22, 24)
MDS_logCPM_treat_strain_genes <- plotMDS(logcpm_treatment[rownames(Dif_gene_time_top4000), ], pch = shape[as.factor(sampleTable_treated$Strain)], 
                                       bg = col.fill[as.factor(sampleTable_treated$Time)], cex = 1.5, lwd = 3, 
                                       gene.selection = "common", plot = TRUE, main = "MDS_air_logCPM_time_genes")
legend("topleft", legend = c("0d", "1h", "6h", "1d", "3d", "7d"), col = col.fill, pch = 15)
legend("topright", legend = c("FW", "HON11"), pch = shape)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_air_logCPM_with_symbol_time_gene.png")
dev.off()
MDS_logCPM_treat <- cbind(sampleTable_treated, MDS_logCPM_treat_strain_genes$cmdscale.out)
write.csv(MDS_logCPM_treat, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_logCPM_treat_time_genes_PCA.csv")
```

#### 6.2 Heatmap for treatment between time points
 
##### 6.2.1 prepare re-ordered sampleTable and data
```
sampleTable_treated.2 <- sampleTable_treated[order(sampleTable_treated$Strain, sampleTable_treated$Time), ]
my_data_time <- logcpm_treat_normalized[rownames(Dif_gene_time_top4000), ]
 # my_data <- log2(my_data+1)
my_data_time <- my_data_time[, row.names(sampleTable_treated.2)]

 # 6.2.2 Draw a heatmap for different time points
my_matrix_time <- as.matrix(my_data_time[, c(1:58)]) # make the heatmap data into a matrix
 # Default parameter Heatmap
dend_time = hclust(dist(my_matrix_time, method = "maximum"), method = "ward.D")
Heatmap(my_matrix_time, cluster_columns = FALSE, 
        show_row_names = FALSE, 
        show_column_names = FALSE, 
        row_names_side = "left", 
        row_dend_side = "left", 
        row_names_gp = gpar(cex = fontsize), 
        row_dend_width = unit(2, "cm"), 
        clustering_distance_rows = "maximum", 
        clustering_method_rows = "ward.D", 
        cluster_rows = color_branches(dend_time, k = 4), 
        bottom_annotation = ha)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Heatmap_time.png")
dev.off()
```

##### 6.2.2 Draw a heatmap for different time points
```
my_matrix_time_no_interaction <- as.matrix(my_data_time_no_interaction[, c(1:58)]) # make the heatmap data into a matrix
 # Default parameter Heatmap
dend_time_no_interaction = hclust(dist(my_matrix_time_no_interaction, method = "maximum"), method = "ward.D")
Heatmap(my_matrix_time_no_interaction, cluster_columns = FALSE, 
        show_row_names = FALSE, 
        show_column_names = FALSE, 
        row_names_side = "left", 
        row_dend_side = "left", 
        row_names_gp = gpar(cex = fontsize), 
        row_dend_width = unit(2, "cm"), 
        clustering_distance_rows = "maximum", 
        clustering_method_rows = "ward.D", 
        cluster_rows = color_branches(dend_time_no_interaction, k = 4), 
        bottom_annotation = ha)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Heatmap_time_no_interaction.png")
dev.off()

strain_T <- sampleTable_treated$Strain
col.fill <- c("blue", "skyblue", "yellow", "pink", "red", "black")
shape <- c(22, 24)
MDS_logCPM_treat_time_no_interaction_genes <- plotMDS(logcpm_treatment[my_data_time_no_interaction_rownames, ], pch = shape[as.factor(sampleTable_treated$Strain)], 
                                                      bg = col.fill[as.factor(sampleTable_treated$Time)], cex = 1.5, lwd = 3, 
                                                      gene.selection = "common", plot = TRUE, main = "MDS_air_logCPM_time_no_interaction_genes")
legend("topleft", legend = c("0d", "1h", "6h", "1d", "3d", "7d"), col = col.fill, pch = 15)
legend("topright", legend = c("FW", "HON11"), pch = shape)
dev.copy(png, "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_air_logCPM_with_symbol_time_no_interaction_gene.png")
dev.off()
MDS_logCPM_treat_time_no_interaction_genes <- cbind(sampleTable_treated, MDS_logCPM_treat_time_no_interaction_genes$cmdscale.out)
write.csv(MDS_logCPM_treat_time_no_interaction_genes, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/MDS_logCPM_treat_time_no_interaction_genes_PCA.csv")
```

##### 6.2.3 Draw a heatmap for different time points without interaction
```
my_data_time_no_interaction_rownames <- rownames(Dif_gene_time_top4000)[!rownames(Dif_gene_time_top4000)%in%Dif_gene_treatment_all_names]
my_data_time_no_interaction <- logcpm_treat_normalized[my_data_time_no_interaction_rownames, ]
 # my_data <- log2(my_data+1)
my_data_time_no_interaction <- my_data_time_no_interaction[, row.names(sampleTable_treated.2)]
```

### 7. Diagram for different time points among two strains
```
library(VennDiagram)
```

#### 7.1 Differential genes between two strains at different time points

##### 7.1.1 Differential genes at 1h between strains
```
Dif_gene_1h_top <- topTable(fit_treatment, coef = 2, adjust.method = "BH", number = 5000, p.value = 0.01)
sum(Dif_gene_1h_top$adj.P.Val<0.01)
Dif_gene_1h_all <- topTable(fit_treatment, coef = 2, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_1h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_1h_all.csv")
 # 7.1.2 Differential genes at 6h between strains
Dif_gene_6h_top <- topTable(fit_treatment, coef = 3, adjust.method = "BH", number = 5000, p.value = 0.01)
sum(Dif_gene_6h_top$adj.P.Val<0.01)
Dif_gene_6h_all <- topTable(fit_treatment, coef = 3, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_6h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_6h_all.csv")
 # 7.1.3 Differential genes at 24h between strains
Dif_gene_24h_top <- topTable(fit_treatment, coef = 4, adjust.method = "BH", number = 5000, p.value = 0.01)
sum(Dif_gene_24h_top$adj.P.Val<0.01)
Dif_gene_24h_all <- topTable(fit_treatment, coef = 4, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_24h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_24h_all.csv")
 # 7.1.4 Differential genes at 72h between strains
Dif_gene_72h_top <- topTable(fit_treatment, coef = 5, adjust.method = "BH", number = 5000, p.value = 0.01)
sum(Dif_gene_72h_top$adj.P.Val<0.01)
Dif_gene_72h_all <- topTable(fit_treatment, coef = 5, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_72h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_72h_all.csv")
 # 7.1.5 Differential genes at 164h between strains
Dif_gene_164h_top <- topTable(fit_treatment, coef = 6, adjust.method = "BH", number = 5000, p.value = 0.01)
sum(Dif_gene_164h_top$adj.P.Val<0.01)
Dif_gene_164h_all <- topTable(fit_treatment, coef = 6, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_164h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_164h_all.csv")
 # 7.1.6 differential genes betwen two strains at 1h, 6h, 24 h, 72h and 164h
venn.diagram(list("1h" = row.names(Dif_gene_1h_top), 
  "6h" = row.names(Dif_gene_6h_top), 
  "24h" = row.names(Dif_gene_24h_top), 
  "72h" = row.names(Dif_gene_72h_top), 
  "164" = row.names(Dif_gene_164h_top)), 
  main = "Dif_in_air_between_strains", 
  main.cex = 2, cex = 1.5, 
  fill = c("yellow", "cyan", "red", "purple", "green"), 
  filename = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Venn_Dif_in_air_between_strains.png")
```

#### 7.2 Differential interaction genes at different time points between strains

##### 7.2.1 Differential interaction genes at 1h between strains
```
Dif_gene_inter_1h_top <- topTable(fit_treatment, coef = 8, adjust.method = "BH", number = 5000, p.value = 0.05)
sum(Dif_gene_inter_1h_top$adj.P.Val<0.05)
Dif_gene_inter_1h_all <- topTable(fit_treatment, coef = 8, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_inter_1h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_inter_1h_all.csv")
```

##### 7.2.2 Differential interaction genes at 6h between strains
```
Dif_gene_inter_6h_top <- topTable(fit_treatment, coef = 9, adjust.method = "BH", number = 5000, p.value = 0.05)
sum(Dif_gene_inter_6h_top$adj.P.Val<0.05)
Dif_gene_inter_6h_all <- topTable(fit_treatment, coef = 9, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_inter_6h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_inter_6h_all.csv")
```

##### 7.2.3 Differential interaction genes at 24h between strains
```
Dif_gene_inter_24h_top <- topTable(fit_treatment, coef = 10, adjust.method = "BH", number = 5000, p.value = 0.05)
sum(Dif_gene_inter_24h_top$adj.P.Val<0.05)
Dif_gene_inter_24h_all <- topTable(fit_treatment, coef = 10, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_inter_24h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_inter_24h_all.csv")
``` 
 
##### 7.2.4 Differential interaction genes at 72h between strains
```
Dif_gene_inter_72h_top <- topTable(fit_treatment, coef = 11, adjust.method = "BH", number = 5000, p.value = 0.05)
sum(Dif_gene_inter_72h_top$adj.P.Val<0.05)
Dif_gene_inter_72h_all <- topTable(fit_treatment, coef = 11, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_inter_72h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_inter_72h_all.csv")
``` 

##### 7.2.5 Differential interaction genes at 164h between strains
```
Dif_gene_inter_164h_top <- topTable(fit_treatment, coef = 12, adjust.method = "BH", number = 5000, p.value = 0.05)
sum(Dif_gene_inter_164h_top$adj.P.Val<0.05)
Dif_gene_inter_164h_all <- topTable(fit_treatment, coef = 12, adjust.method = "BH", number = Inf)
write.csv(Dif_gene_inter_164h_all, file = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Dif_gene_inter_164h_all.csv")
```

##### 7.2.6 Differential interaction genes betwen two strains at 1h, 6h, 24 h, 72h and 164h
```
venn.diagram(list("1h" = row.names(Dif_gene_inter_1h_top), 
                  "6h" = row.names(Dif_gene_inter_6h_top), 
                  "24h" = row.names(Dif_gene_inter_24h_top), 
                  "72h" = row.names(Dif_gene_inter_72h_top), 
                  "164" = row.names(Dif_gene_inter_164h_top)), 
             main = "Dif_in_air_inter_between_strains", 
             main.cex = 2, cex = 1.5, 
             fill = c("yellow", "cyan", "red", "purple", "green"), 
             filename = "D:/mangrove_killifish_project/limma/limma_with_seperate_counts/output/Venn_Dif_inter_in_air_between_strains.png")
```

### 8. PCA analysis for all samples in water
```
library(devtools)
```

#### 8.1 All samples in water PCA analysis
```
# ir_log_control <- log2(x_control+1)
# ir_log_control <- prcomp(ir_log_control, center = TRUE, scale. = TRUE) # pca analysis
# summary(ir_log_control)
# predict(ir_log_control)

sessionInfo()
```

