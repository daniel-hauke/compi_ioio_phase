#-------------------------------------------------------------------------------
# This script analyzes participants demographics of the sample.
#-------------------------------------------------------------------------------
#-----------------------------
# Load Packages
#-----------------------------
# Uncomment next line to install package manager, if needed
#install.packages('pacman')

pacman::p_load(xlsx,
               psych,
               car,
               ggplot2)


#-----------------------------------------
# Load data
#-----------------------------------------
# Adapt project root to the project root on your computer
root_project = 'C:/projects/compi_ioio_phase/'

# Get data root
root_data    = paste0(root_project, 'data/clinical/')

# Define file name
fname_data   = 'clinical'

# Load data
data = read.xlsx(paste0(root_data, fname_data,'.xlsx'),
                     as.data.frame = T, 
                     header = T,
                     sheetIndex = 1)


# Make sure -999 is coded as NA
data[data == -999] = NA


#-----------------------------------------
# Prepare data.frame
#-----------------------------------------
# Get subject IDs
subjects = as.factor(data$id)

# Group
group = factor(data$group_verb, levels = c('HC','CHR','FEP'))

# Get demographic variables
age = data$SocDem_age
iq = as.numeric(data$MWT_IQ)
wm = data$DS_backward
sex = factor(data$SocDem_sex)
antipsych = factor(data$medication_antipsych_T0, levels = c(1,0), labels = c('y','n'))
antidep = factor(data$medication_antidep_T0, levels = c(1,0), labels = c('y','n'))
chlor_eq = data$chlor_eq_dose_T0
fluox_eq = data$fluox_eq_dose_T0
cannabis = factor(data$SocDem_cannabis_T0, levels = c(1,0), labels = c('y','n'))


# PANSS
PANSS_P = as.numeric(rowSums(data.matrix(data[,grepl('PANSS_P\\d_T0', colnames(data))])))
PANSS_N = as.numeric(rowSums(data.matrix(data[,grepl('PANSS_N\\d_T0', colnames(data))])))
PANSS_G = as.numeric(rowSums(data.matrix(data[,grepl('PANSS_G\\d_T0|PANSS_G\\d\\d_T0', colnames(data))])))

# PCL
pcl_freq = data.matrix(data[,grepl('PCL_freq_\\d_T0|PCL_freq_\\d\\d_T0', colnames(data))])
pcl_freq[28,7] = median(pcl_freq[group=='CHR',7], na.rm = T) # Median imputation
pcl_freq = as.numeric(rowSums(pcl_freq))

pcl_conv = data.matrix(data[,grepl('PCL_conv_\\d_T0|PCL_conv_\\d\\d_T0', colnames(data))])
pcl_conv = as.numeric(rowSums(pcl_conv))

pcl_dist = data.matrix(data[,grepl('PCL_dist_\\d_T0|PCL_dist_\\d\\d_T0', colnames(data))])
pcl_dist[22,16] = median(pcl_dist[group=='CHR',16], na.rm = T) # Median imputation
pcl_dist = as.numeric(rowSums(pcl_dist))

# Days medicated before the EEG measurement
days_medicated = data$days_medicated_before_eeg

options(scipen=999) # Turn scientific notation off



#-----------------------------------------
# Analyze demographic characteristics
#-----------------------------------------
# Age
hist(age)
describeBy(age, group)
Anova(lm(age~group), type = 'III', test.statistic = 'F')
pairwise.t.test(age, group, p.adjust.method = 'bonferroni', paired = F)


# IQ
hist(iq)
describeBy(iq, group)
Anova(lm(iq~group), type = 'III', test.statistic = 'F')
pairwise.t.test(iq, group, p.adjust.method = 'bonferroni', paired = F)


# WM
hist(wm)
describeBy(wm, group)
Anova(lm(wm~group), type = 'III', test.statistic = 'F')
pairwise.t.test(wm, group, p.adjust.method = 'bonferroni', paired = F)


# Sex
xtabs(~ sex + group)
chisq.test(xtabs(~ sex + group), correct = F)



#-----------------------------------------
# Analyze clinical characteristics
#-----------------------------------------
# Days medicated
hist(days_medicated)
describe(days_medicated)


# Antipsych
xtabs(~ antipsych + group)
chisq.test(xtabs(~ antipsych + group), correct = F)

cat('CHR vs FEP')
chisq.test(xtabs(~ antipsych[group !='HC'] + group[group !='HC'], drop.unused.levels = T), correct = F)
cat('HC vs FEP')
chisq.test(xtabs(~ antipsych[group !='CHR'] + group[group !='CHR'], drop.unused.levels = T), correct = F)
cat('HC vs CHR')
chisq.test(xtabs(~ antipsych[group !='FEP'] + group[group !='FEP'], drop.unused.levels = T), correct = F)


# Antidep
xtabs(~ antidep + group)
chisq.test(xtabs(~ antidep + group), correct = F)

cat('CHR vs FEP')
chisq.test(xtabs(~ antidep[group !='HC'] + group[group !='HC'], drop.unused.levels = T), correct = F)
cat('HC vs FEP')
chisq.test(xtabs(~ antidep[group !='CHR'] + group[group !='CHR'], drop.unused.levels = T), correct = F)
cat('HC vs CHR')
chisq.test(xtabs(~ antidep[group !='FEP'] + group[group !='FEP'], drop.unused.levels = T), correct = F)


# Chlorpromazine equivalent doses
hist(chlor_eq)
describeBy(chlor_eq, group)
quantile(chlor_eq[group=='HC'], probs = c(.25,.75), na.rm = T)
quantile(chlor_eq[group=='CHR'], probs = c(.25,.75), na.rm = T)
quantile(chlor_eq[group=='FEP'], probs = c(.25,.75), na.rm = T)
res = kruskal.test(chlor_eq, group)
eta_squared = res$statistic/(sum(!is.na(chlor_eq))-1)
res
eta_squared
pairwise.wilcox.test(chlor_eq, group, p.adjust.method = 'bonferroni')


# Fluxoetine equivalent doses
hist(fluox_eq)
describeBy(fluox_eq, group)
quantile(fluox_eq[group=='HC'], probs = c(.25,.75), na.rm = T)
quantile(fluox_eq[group=='CHR'], probs = c(.25,.75), na.rm = T)
quantile(fluox_eq[group=='FEP'], probs = c(.25,.75), na.rm = T)
res = kruskal.test(fluox_eq, group)
eta_squared = res$statistic/(sum(!is.na(fluox_eq))-1)
res
eta_squared
pairwise.wilcox.test(fluox_eq, group, p.adjust.method = 'bonferroni')

# WM
hist(wm)
describeBy(wm, group)
Anova(lm(wm~group), type = 'III', test.statistic = 'F')
pairwise.t.test(wm, group, p.adjust.method = 'bonferroni', paired = F)


# Cannabis
xtabs(~ cannabis + group)
chisq.test(xtabs(~ cannabis + group), correct = F)


# PANSS P
summary(PANSS_P[group=='HC'])
sum(!is.na(PANSS_P[group=='HC']))

summary(PANSS_P[group=='CHR'])
sum(!is.na(PANSS_P[group=='CHR']))

summary(PANSS_P[group=='FEP'])
sum(!is.na(PANSS_P[group=='FEP']))

res = kruskal.test(PANSS_P, group)
eta_squared = res$statistic/(sum(!is.na(PANSS_P))-1)
res
eta_squared

pairwise.wilcox.test(PANSS_P, group, p.adjust.method = 'bonferroni')


# PANSS N
summary(PANSS_N[group=='HC'])
sum(!is.na(PANSS_N[group=='HC']))

summary(PANSS_N[group=='CHR'])
sum(!is.na(PANSS_N[group=='CHR']))

summary(PANSS_N[group=='FEP'])
sum(!is.na(PANSS_N[group=='FEP']))

res = kruskal.test(PANSS_N, group)
eta_squared = res$statistic/(sum(!is.na(PANSS_N))-1)
res
eta_squared

pairwise.wilcox.test(PANSS_N, group, p.adjust.method = 'bonferroni')


# PANSS G
summary(PANSS_G[group=='HC'])
sum(!is.na(PANSS_G[group=='HC']))

summary(PANSS_G[group=='CHR'])
sum(!is.na(PANSS_G[group=='CHR']))

summary(PANSS_G[group=='FEP'])
sum(!is.na(PANSS_G[group=='FEP']))

res = kruskal.test(PANSS_G, group)
eta_squared = res$statistic/(sum(!is.na(PANSS_G))-1)
res
eta_squared

pairwise.wilcox.test(PANSS_G, group, p.adjust.method = 'bonferroni', paired = F)


# PCL freq
describeBy(pcl_freq, group)
quantile(pcl_freq[group=='HC'], probs = c(.25,.75), na.rm = T)
quantile(pcl_freq[group=='CHR'], probs = c(.25,.75), na.rm = T)
quantile(pcl_freq[group=='FEP'], probs = c(.25,.75), na.rm = T)

res = kruskal.test(pcl_freq, group)
eta_squared = res$statistic/(sum(!is.na(pcl_freq))-1)
res
eta_squared

pairwise.wilcox.test(pcl_freq, group, p.adjust.method = 'bonferroni', paired = F)


# PCL conviction
describeBy(pcl_conv, group)
quantile(pcl_conv[group=='HC'], probs = c(.25,.75), na.rm = T)
quantile(pcl_conv[group=='CHR'], probs = c(.25,.75), na.rm = T)
quantile(pcl_conv[group=='FEP'], probs = c(.25,.75), na.rm = T)

res = kruskal.test(pcl_conv, group)
eta_squared = res$statistic/(sum(!is.na(pcl_conv))-1)
res
eta_squared


# PCL distress
describeBy(pcl_dist, group)
quantile(pcl_dist[group=='HC'], probs = c(.25,.75), na.rm = T)
quantile(pcl_dist[group=='CHR'], probs = c(.25,.75), na.rm = T)
quantile(pcl_dist[group=='FEP'], probs = c(.25,.75), na.rm = T)

res = kruskal.test(pcl_dist, group)
eta_squared = res$statistic/(sum(!is.na(pcl_dist))-1)
res
eta_squared



