#-------------------------------------------------------------------------------
# This script analyzes participants behavior and performs posterior predictive 
# checks on the model predictions.
#-------------------------------------------------------------------------------
#---------------------------------------
# Load Packages
#---------------------------------------
# Uncomment next line to install package manager, if needed
#install.packages('pacman')

pacman::p_load(xlsx, 
               reshape2,
               ggplot2,
               plyr,
               gridExtra,
               lme4,
               car,
               lsmeans)


#---------------------------------------
# Load data
#---------------------------------------
# Adapt project root to the project root on your computer
root_project = 'C:/projects/compi_ioio_phase/'


# Get data roots and save directory
root_save = paste0(root_project, 'results/figures_paper/')
root_probs = paste0(root_project, 'results/diag_hgf/ms1/m3/')
root_choices = paste0(root_project, 'results/results_behav/')


# Define file names
fname_choices = 'compi_choices'
fname_probs = 'pred_responses'


# Load choice data
temp = read.xlsx(paste0(root_choices, fname_choices,'.xlsx'),
                     as.data.frame = T, 
                     header = T,
                     sheetIndex = 1)

# Get choices
choices = temp[,7:ncol(temp)]
rm(temp)

# Load prob data
temp = read.xlsx(paste0(root_probs, fname_probs,'.xlsx'),
                     as.data.frame = T, 
                     header = T,
                     sheetIndex = 1)
probs = temp[,7:ncol(temp)]


# Get other variables
subjects = as.factor(temp [,1])
n_trials = dim(choices)[2]
subjects = as.factor(temp [,1])
group = factor(temp [,2],
               levels = c('HC','CHR','FEP'),
               labels = c('HC','CHR-P','FEP'))

# Covariates
age = temp[,3]
age_z = (age-mean(age))/sd(age)
wm = temp[,4]
wm_z = (wm-mean(wm))/sd(wm)
antipsych = factor(temp[,5], 
                   levels = c(0,1), 
                   labels = c('no','yes'))
antidep = factor(temp[,6], 
                 levels = c(0,1), 
                 labels = c('no','yes'))


#---------------------------------------
# Compute AT per phase
#---------------------------------------
trials_stable  = 1:34
trials_volatile  = 35:136

AT_overall_choice  = rowMeans(choices,na.rm = T)
AT_stable_choice = rowMeans(choices[,trials_stable],na.rm = T)
AT_volatile_choice = rowMeans(choices[,trials_volatile],na.rm = T)


# Prepare data
data_wide_choice = data.frame(subjects, group, age_z, wm_z, antipsych, antidep, AT_stable_choice, AT_volatile_choice)
data_long_choice = melt(data_wide_choice,
                 id.vars = c('subjects', 'group',  'age_z', 'wm_z', 'antipsych', 'antidep'),
                 variable.name = 'phase',
                 value.name = 'AT')
levels(data_long_choice$phase) = c('Stable', 'Volatile')


#---------------------------------------
# Analysis
#---------------------------------------
# Statistical analysis: Phase
cat('--------------------------\nAdvice Taking * phase\n--------------------------')
m_choice = lmer(AT ~ group*phase  + wm_z + antipsych + antidep + age_z +(1|subjects), data = data_long_choice)
Anova(m_choice, type = 'III', test.statistic = 'F')

cat('--------------------------\nTest for normality\n--------------------------')
shapiro.test(resid(m_choice))

cat('--------------------------\nPosthoc tests\n--------------------------')
m_choice_hc_chr = lmer(AT ~ group*phase  + wm_z + antipsych + antidep + age_z +(1|subjects), data = data_long_choice[data_long_choice$group!='FEP',])
Anova(m_choice_hc_chr, type = 'III', test.statistic = 'F')

m_choice_hc_fep = lmer(AT ~ group*phase  + wm_z + antipsych + antidep + age_z +(1|subjects), data = data_long_choice[data_long_choice$group!='CHR-P',])
Anova(m_choice_hc_fep, type = 'III', test.statistic = 'F')

m_choice_chr_fep = lmer(AT ~ group*phase  + wm_z + antipsych + antidep + age_z +(1|subjects), data = data_long_choice[data_long_choice$group!='HC',])
Anova(m_choice_chr_fep, type = 'III', test.statistic = 'F')


#---------------------------------------
# Plot Ground Truth
#---------------------------------------
h1 = .872
h2 = .9
h3 = .925

summary <- ddply(data_long_choice, .(group, phase), summarise, AT = mean(AT))

windowsFonts(Calibri = windowsFont("Calibri"))
colors = c('HC' = '#ffeda0', 'CHR-P' = '#feb24c', 'FEP' = '#f03b20') 
colors = c('HC' = '#fe9929', 'CHR-P' = '#d95f0e', 'FEP' = '#993404') 

set.seed(555) # to fix jitter
p1 <- ggplot(data_long_choice, aes(x = phase, y = AT, fill = group)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(position = position_jitterdodge(dodge.width = 0.75, jitter.width = .3), alpha = .3) +
  labs(title="Ground Truth", y = "Advice Taking", x = 'Phase') +
  scale_y_continuous(limits = c(0.35, .95)) +
  scale_fill_manual(values = colors) +
  geom_point(data = summary, size = 2, shape = 22, position = position_dodge(width=0.75), show.legend = F) +
  scale_shape_identity() +
  theme_classic() +
  theme(text = element_text (family = "Calibri", size = 15, face = 'bold', color = 'black'),
        legend.position = 'none',
        axis.title.x = element_text(color='black'),
        axis.title.y = element_text(color='black'),
        axis.text.y = element_text(color='black'),
        axis.text.x = element_text(color='black'))
p1
# ggsave(paste0(root_save,'AT_per_phase_and_group.png'),
#        width = 8, height = 8, dpi = 300,
#        units = "cm")



#---------------------------------------
# Compute predicted AT per phase
#---------------------------------------
trials_stable = 1:34
trials_volatile = 35:136

AT_overall_pred  = rowMeans(probs,na.rm = T)
AT_stable_pred = rowMeans(probs[,trials_stable],na.rm = T)
AT_volatile_pred = rowMeans(probs[,trials_volatile],na.rm = T)


# Prepare data
data_wide_pred = data.frame(subjects, group, age_z, wm_z, antipsych, antidep, AT_stable_pred, AT_volatile_pred)
data_long_pred = melt(data_wide_pred,
                 id.vars = c('subjects', 'group',  'age_z', 'wm_z', 'antipsych', 'antidep'),
                 variable.name = 'phase',
                 value.name = 'AT')
levels(data_long_pred$phase) = c('Stable', 'Volatile')


#---------------------------------------
# Statistical analysis: Phase
#---------------------------------------
cat('--------------------------\nAdvice Taking * phase\n--------------------------')
m_pred = lmer(AT ~ group*phase  + wm_z + antipsych + antidep + age_z +(1|subjects), data = data_long_pred)
Anova(m_pred, type = 'III', test.statistic = 'F')

cat('--------------------------\nTest for normality\n--------------------------')
shapiro.test(resid(m_pred))

cat('--------------------------\nPosthoc tests\n--------------------------')
m_pred_hc_chr = lmer(AT ~ group*phase  + wm_z + antipsych + antidep + age_z +(1|subjects), data = data_long_pred[data_long_pred$group!='FEP',])
Anova(m_pred_hc_chr, type = 'III', test.statistic = 'F')

m_pred_hc_fep = lmer(AT ~ group*phase  + wm_z + antipsych + antidep + age_z +(1|subjects), data = data_long_pred[data_long_pred$group!='CHR-P',])
Anova(m_pred_hc_fep, type = 'III', test.statistic = 'F')

m_pred_chr_fep = lmer(AT ~ group*phase  + wm_z + antipsych + antidep + age_z +(1|subjects), data = data_long_pred[data_long_pred$group!='HC',])
Anova(m_pred_chr_fep, type = 'III', test.statistic = 'F')


#---------------------------------------
# Plot Model prediction
#---------------------------------------
h1 = .875
h2 = .9
h3 = .925
summary <- ddply(data_long_pred, .(group, phase), summarise, AT = mean(AT))
colors = c('HC' = '#ffeda0', 'CHR-P' = '#feb24c', 'FEP' = '#f03b20')
colors = c('HC' = '#fe9929', 'CHR-P' = '#d95f0e', 'FEP' = '#993404') 

set.seed(555) # to fix jitter
p2 <- ggplot(data_long_pred, aes(x = phase, y = AT, fill = group)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(position = position_jitterdodge(dodge.width = 0.75, jitter.width = .3), alpha = .3) +
  labs(title="Model Prediction", y = "Advice Taking", x = 'Phase') +
  scale_fill_manual(values = colors) +
  scale_y_continuous(limits = c(0.35, .95)) +
  geom_point(data = summary, size = 2, shape = 22, position = position_dodge(width=0.75), show.legend = F) +
  scale_shape_identity() +
  theme_classic() +
  theme(text = element_text (family = "Calibri", size = 15, face = 'bold', color = 'black'),
        #legend.position = 'none')
        legend.position = c(0.2, 0.2), legend.title=element_blank(),
        legend.background = element_rect(fill='transparent'), #transparent legend bg
        legend.box.background = element_rect(fill='transparent', color = 'transparent'), #transparent legend panel
        axis.title.x = element_text(color='black'),
        axis.title.y = element_text(color='black'),
        axis.text.y = element_text(color='black'),
        axis.text.x = element_text(color='black'))
p2
# ggsave(paste0(root_save,'pred_AT_per_phase_and_group.png'),
#        width = 8, height = 8, dpi = 300,
#        units = "cm")


#---------------------------------------
# Create multiplot
#---------------------------------------
p3 <- grid.arrange(p1, p2, ncol = 2)
ggsave(paste0(root_save,'AT_vs_model_prediction.png'),
       plot = p3, 
       width = 15, height = 8, dpi = 300,
       units = "cm")



