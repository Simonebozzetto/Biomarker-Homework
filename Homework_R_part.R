library(R.matlab)

# Leggi il file .mat
data <- readMat("C:/Università/Magistrale/1_Primo_Anno/2_Biomarkers_Precision_Medicine_and_Drug_Development/Homework/Dati/Data_Homework_for_R.mat")
sex_factor <- as.factor(data$sex)
genotype_factor <- as.factor(data$genotype)

library(ARTool)

# Modello ART ANOVA
model_thalamus <- art(LI.Vt[,1] ~ genotype_factor * sex_factor, data = data)
model_putamen <- art(LI.Vt[,2] ~ genotype_factor * sex_factor, data = data)
model_cerebellum <- art(LI.Vt[,3] ~ genotype_factor * sex_factor, data = data)
model_occipital <- art(LI.Vt[,4] ~ genotype_factor * sex_factor, data = data)
model_frontal <- art(LI.Vt[,6] ~ genotype_factor * sex_factor, data = data)

# ANOVA
anova(model_thalamus)
anova(model_putamen)
anova(model_cerebellum)
anova(model_occipital)
anova(model_frontal)

library(ggplot2)
library(dplyr)

plot_data <- data.frame(
  value = data$LI.Vt[, 3],
  genotype = genotype_factor,
  sex = sex_factor
)

# Barplot con media e errore standard
# Sex 
#   2 -> male
#   1 -> female
# Genotype
#   2 -> MAB
#   1 -> HAB

ggplot(plot_data, aes(x = sex, y = value, fill = genotype)) +
  stat_summary(fun = mean, geom = "bar", position = position_dodge(), width = 0.6) +
  stat_summary(fun.data = mean_se, geom = "errorbar", 
               position = position_dodge(0.6), width = 0.2) +
  labs(title = "Interaction Genotype x Sex", 
       x = "sex", y = "LI_Vt of Cerebellum") +
  theme_minimal()

###############################################################################