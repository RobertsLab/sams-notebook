#!/usr/bin/env Rscript

# Load required libraries
library(tidyverse)
library(ggplot2)
library(car)
library(emmeans)

# Load data
citrate_synthase_01 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-27-qPCRs---M.gigas-Valentina-PolyIC-cGAS-citrate_synthase-and-DNMT1/sam_2026-01-27_15-32-08_Connect-citrate_synthase-01--Quantification-Cq_Results.csv") %>%
  mutate(Target = "Citrate.Synthase")
citrate_synthase_02 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-27-qPCRs---M.gigas-Valentina-PolyIC-cGAS-citrate_synthase-and-DNMT1/sam_2026-01-27_15-30-47_CFX96-citrate_synthase-02-Quantification-Cq_Results.csv") %>%
  mutate(Target = "Citrate.Synthase")
citrate_synthase_03 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-27-qPCRs---M.gigas-Valentina-PolyIC-cGAS-citrate_synthase-and-DNMT1/sam_2026-01-27_16-31-12_Connect-citrate_synthase-03-Quantification-Cq_Results.csv") %>%
  mutate(Target = "Citrate.Synthase")

DNMT1_01 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-27-qPCRs---M.gigas-Valentina-PolyIC-cGAS-citrate_synthase-and-DNMT1/sam_2026-01-27_13-34-02_Connect-DNMT1-01-Quantification-Cq_Results.csv") %>%
  mutate(Target = "DNMT1")
DNMT1_02 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-27-qPCRs---M.gigas-Valentina-PolyIC-cGAS-citrate_synthase-and-DNMT1/sam_2026-01-27_13-29-34_CFX96-DNMT1-02%20Quantification-Cq_Results.csv") %>%
  mutate(Target = "DNMT1")
DNMT1_03 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-27-qPCRs---M.gigas-Valentina-PolyIC-cGAS-citrate_synthase-and-DNMT1/sam_2026-01-27_14-33-31_Connect-DNMT1-03-Quantification-Cq_Results.csv") %>%
  mutate(Target = "DNMT1")

cGAS_01 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-27-qPCRs---M.gigas-Valentina-PolyIC-cGAS-citrate_synthase-and-DNMT1/sam_2026-01-27_11-25-14_Connect-cGAS-01-Quantification-Cq_Results.csv") %>%
  mutate(Target = "cGAS")
cGAS_02 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-27-qPCRs---M.gigas-Valentina-PolyIC-cGAS-citrate_synthase-and-DNMT1/sam_2026-01-27_11-49-08_CFX96-cGAS-02-Quantification-Cq_Results.csv") %>%
  mutate(Target = "cGAS")
cGAS_03 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-27-qPCRs---M.gigas-Valentina-PolyIC-cGAS-citrate_synthase-and-DNMT1/sam_2026-01-27_12-35-04_Connect-cGAS-03-QuantificationCq_Results.csv") %>%
  mutate(Target = "cGAS")

ATP_synthase_01 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_09-56-00_Connect-ATP_synthase-01-QuantificationCq_Results.csv") %>%
  mutate(Target = "ATP.Synthase")
ATP_synthase_02 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_10-13-15_CFX96-ATP_synthase-02-Quantification-Cq_Results.csv") %>%
  mutate(Target = "ATP.Synthase")
ATP_synthase_03 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_10-55-49_Connect-ATP_synthase-03-Quantification-Cq_Results.csv") %>%
  mutate(Target = "ATP.Synthase")

GAPDH_01 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_12-06-16_Connect-GAPDH-01-Quantification-Cq_Results.csv") %>%
  mutate(Target = "GAPDH")
GAPDH_02 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_12-07-20_CFX96-GAPDH-02-Quantification-Cq_Results.csv") %>%
  mutate(Target = "GAPDH")
GAPDH_03 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_13-05-59_Connect-GAPDH-03-Quantification-Cq_Results.csv") %>%
  mutate(Target = "GAPDH")

HSP70_01 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_14-03-35_Connect-HSP70-01-Quantification-Cq_Results.csv") %>%
  mutate(Target = "HSP70")
HSP70_02 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_14-25-31_CFX96-HSP70-02-Quantification-Cq_Results.csv") %>%
  mutate(Target = "HSP70")
HSP70_03 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_15-00-57_Connect-HSP70-03-Quantification-Cq_Results.csv") %>%
  mutate(Target = "HSP70")

HSP90_01 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28-16-06-43_Connect-HSP90-01-QuantificationCq_Results.csv") %>%
  mutate(Target = "HSP90")
HSP90_02 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_16-07-47_CFX96-HSP90-02-Quantification-Cq_Results.csv") %>%
  mutate(Target = "HSP90")
HSP90_03 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-28-qPCRs---M.gigas-Valentina-PolyIC-ATP-synthase-GAPDH-HSP70-and-HSP90/sam_2026-01-28_17-07-09_Connect-HSP90-03-Quantification-Cq_Results.csv") %>%
  mutate(Target = "HSP90")

VIPERIN_01 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-29-qPCR---M.gigas-Valentina-PolyIC-VIPERIN/sam_2026-01-29_07-21-16_Connect-VIPERIN-01-QuantificationCq_Results.csv") %>%
  mutate(Target = "VIPERIN")
VIPERIN_02 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-29-qPCR---M.gigas-Valentina-PolyIC-VIPERIN/sam_2026-01-29_07-39-06_CFX96-VIPERIN-02-Quantification-Cq_Results.csv") %>%
  mutate(Target = "VIPERIN")
VIPERIN_03 <- read.csv("https://raw.githubusercontent.com/RobertsLab/sams-notebook/refs/heads/master/posts/2026/2026-01-29-qPCR---M.gigas-Valentina-PolyIC-VIPERIN/sam_2026-01-29_08-24-59_Connect-VIPERIN-03-QuantificationCq_Results.csv") %>%
  mutate(Target = "VIPERIN")

# Combine data
citrate_synthase <- bind_rows(citrate_synthase_01, citrate_synthase_02, citrate_synthase_03)
DNMT1 <- bind_rows(DNMT1_01, DNMT1_02, DNMT1_03)
cGAS <- bind_rows(cGAS_01, cGAS_02, cGAS_03)
ATP_synthase <- bind_rows(ATP_synthase_01, ATP_synthase_02, ATP_synthase_03)
GAPDH <- bind_rows(GAPDH_01, GAPDH_02, GAPDH_03)
HSP70 <- bind_rows(HSP70_01, HSP70_02, HSP70_03)
HSP90 <- bind_rows(HSP90_01, HSP90_02, HSP90_03)
VIPERIN <- bind_rows(VIPERIN_01, VIPERIN_02, VIPERIN_03)

qpcr_data <- bind_rows(citrate_synthase, DNMT1, cGAS, ATP_synthase, GAPDH, HSP70, HSP90, VIPERIN)

# Data cleaning
qpcr_data <- qpcr_data %>%
  filter(Sample != "NTC" & !is.na(Sample) & Sample != "")

qpcr_data <- qpcr_data[!is.na(qpcr_data$Cq.Std..Dev), ]

qpcr_filtered <- qpcr_data %>%
  group_by(Sample, Target) %>%
  filter(n() == 1 | abs(Cq - median(Cq, na.rm = TRUE)) <= 0.5) %>%
  ungroup()

grouped_df <- qpcr_filtered %>%
  group_by(Sample, Target) %>%
  summarise(
    Cq.Mean = mean(Cq, na.rm = TRUE),
    Cq.Std..Dev = sd(Cq, na.rm = TRUE),
    .groups = 'drop'
  )

grouped_df <- grouped_df %>%
  mutate(
    bio_replicate = str_extract(Sample, "^[A-Z]"),
    replicate_num = str_extract(Sample, "\\d+"),
    polyIC = ifelse(str_detect(Sample, "P"), "PolyIC", "No_PolyIC"),
    stress_type = case_when(
      str_detect(Sample, "C$") ~ "Control",
      str_detect(Sample, "T$") ~ "Temperature",
      str_detect(Sample, "M$") ~ "Mechanical",
      TRUE ~ NA_character_
    ),
    treatment_group = paste(polyIC, stress_type, sep = "_")
  )

calculate_delta_Cq <- function(df) {
  df <- df %>%
    group_by(Sample) %>%
    mutate(delta_Cq = Cq.Mean - Cq.Mean[Target == "GAPDH"]) %>%
    ungroup()
  return(df)
}

delta_Cq_df <- calculate_delta_Cq(grouped_df)
delta_Cq_df <- delta_Cq_df %>%
  filter(Target != "GAPDH")

# Run ANOVA for each gene and capture results
cat("\n==================== ANOVA RESULTS ====================\n\n")

genes <- c("ATP.Synthase", "Citrate.Synthase", "DNMT1", "HSP70", "HSP90", "cGAS", "VIPERIN")

for (gene in genes) {
  cat("\n\n========================================\n")
  cat(gene, "\n")
  cat("========================================\n\n")
  
  gene_data <- delta_Cq_df %>% filter(Target == gene)
  model <- aov(delta_Cq ~ polyIC * stress_type, data = gene_data)
  
  cat("--- ANOVA Table ---\n")
  print(summary(model))
  
  cat("\n--- Levene's Test ---\n")
  levene_result <- leveneTest(model$residuals ~ polyIC * stress_type, data = gene_data)
  print(levene_result)
  
  anova_results <- summary(model)[[1]]
  rownames(anova_results) <- trimws(rownames(anova_results))
  
  # Check for significant effects
  if(any(anova_results[["Pr(>F)"]][1:3] < 0.05, na.rm = TRUE)) {
    cat("\n--- Post-hoc Pairwise Contrasts ---\n")
    emm <- emmeans(model, ~ polyIC * stress_type)
    pairs_result <- pairs(emm)
    print(pairs_result)
    
    pairs_df <- as.data.frame(pairs_result)
    sig_contrasts <- pairs_df[pairs_df$p.value <= 0.05, ]
    
    if(nrow(sig_contrasts) > 0) {
      cat("\nSignificant contrasts (p ≤ 0.05):\n")
      for(i in 1:nrow(sig_contrasts)) {
        cat("-", sig_contrasts$contrast[i], "(p =", round(sig_contrasts$p.value[i], 4), ")\n")
      }
    } else {
      cat("\nNo significant pairwise contrasts found.\n")
    }
  }
}

cat("\n\n==================== DONE ====================\n")
