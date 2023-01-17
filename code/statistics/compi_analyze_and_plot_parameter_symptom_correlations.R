#-------------------------------------------------------------------------------
# This script analyzes and plots parameter-symptom correlations.
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
#root_project = 'C:/projects/compi_ioio_phase/'
root_project = 'C:/Users/danie/Desktop/compi_ioio_phase/'

# Get data root
root_clinic  = paste0(root_project, 'data/clinical/')
root_params  = paste0(root_project, 'results/diag_hgf/ms1/m3/')
root_save    = paste0(root_project, 'results/figures_paper/')

# Define file names
fname_clinic = 'clinical'
fname_params = 'hgf_parameters'

# Load data
data_param = read.xlsx(paste0(root_params, fname_params,'.xlsx'),
                     as.data.frame = T, 
                     header = T,
                     sheetIndex = 1)

data_clinic = read.xlsx(paste0(root_clinic, fname_clinic,'.xlsx'),
                     as.data.frame = T, 
                     header = T,
                     sheetIndex = 1)

# check if IDs match
data_param = data_param[order(data_param$subject),] # order subjects to match IDs
data_clinic = data_clinic[order(data_clinic$id),] # order subjects to match IDs
data_param$subject==data_clinic$id

# Make sure -999 is coded as NA
data_clinic[data_clinic == -999] = NA



#-----------------------------------------
# Prepare data.frame
#-----------------------------------------
# Group
group = factor(data_clinic$group_verb, levels = c('HC','CHR','FEP'))

# PANSS
PANSS_P = as.numeric(rowSums(data.matrix(data_clinic[,grepl('PANSS_P\\d_T0', colnames(data_clinic))])))
PANSS_N = as.numeric(rowSums(data.matrix(data_clinic[,grepl('PANSS_N\\d_T0', colnames(data_clinic))])))
PANSS_G = as.numeric(rowSums(data.matrix(data_clinic[,grepl('PANSS_G\\d_T0|PANSS_G\\d\\d_T0', colnames(data_clinic))])))
PANSS = data.frame(PANSS_P, PANSS_N, PANSS_G)


# PCL
pcl_freq = data.matrix(data_clinic[,grepl('PCL_freq_\\d_T0|PCL_freq_\\d\\d_T0', colnames(data_clinic))])
pcl_freq[28,7] = median(pcl_freq[group=='CHR',7], na.rm = T) # Median imputation
pcl_freq = as.numeric(rowSums(pcl_freq))

pcl_conv = data.matrix(data_clinic[,grepl('PCL_conv_\\d_T0|PCL_conv_\\d\\d_T0', colnames(data_clinic))])
pcl_conv = as.numeric(rowSums(pcl_conv))

pcl_dist = data.matrix(data_clinic[,grepl('PCL_dist_\\d_T0|PCL_dist_\\d\\d_T0', colnames(data_clinic))])
pcl_dist[22,16] = median(pcl_dist[group=='CHR',16], na.rm = T) # Median imputation
pcl_dist = as.numeric(rowSums(pcl_dist))

pcl = data.frame(pcl_freq,pcl_conv,pcl_dist)


# Parameters (only looking at significant parameters)
which_params ='m_3|ka_2'
params = data_param[,grepl(which_params,colnames(data_param))]

options(scipen=999) # turn scientific notation off for readibility

# Exclude outlier kappa subject (ID = COMPI_0070)
# params = params[data_param$subject!='COMPI_0070',c(9:10)]
# PANSS = PANSS[data_clinical$id!='COMPI_0070',]



#-----------------------------------------
# Symptom-parameter correlations
#-----------------------------------------
#--------------------------------
# PANSS-parameter correlations
#--------------------------------
n.params = dim(params)[2]
n.symptoms = dim(PANSS)[2]
n.comp = n.params * n.symptoms

p = vector(mode = 'numeric', length = n.comp)
tau = vector(mode = 'numeric', length = n.comp)
parameter = vector(mode = 'character', length = n.comp)
symptom = vector(mode = 'character', length = n.comp)

c = 1
for (i in 1:n.params){
  cat(paste0('\n---------------------------\n ', colnames(params)[i], '\n---------------------------'))
  for (j in 1:n.symptoms){
    cat(paste0('\n---------------------\n ',colnames(PANSS)[j], '\n---------------------\n'))
    res = cor.test(PANSS[,j], params[,i], method ="kendall")
    p[c] = res$p.value
    tau[c] = res$estimate
    parameter[c] = colnames(params)[i]
    symptom[c] = colnames(PANSS)[j]
    print(res)
    c = c+1
  }
}

# Summarize results
p.fdr =  p.adjust(p, method = 'fdr')
p.bf =  p.adjust(p, method = 'bonferroni')
sign = as.numeric(p < 0.05)
sign.fdr = as.numeric(p.fdr < 0.05)
sign.bf = as.numeric(p.bf < 0.05)

cat(paste0('\n---------------------------\nSummary\n---------------------------'))
print(data.frame(parameter, symptom, tau, p, p.fdr, p.bf, sign, sign.fdr, sign.bf), row.names = F)



#--------------------------------
# Plots on raw data
#--------------------------------
# PANSS P and m3
corplot_data = data.frame(PANSS_P, params$m_3, group)
colnames(corplot_data) = c('PANSS', 'param')
corplot_data = corplot_data[complete.cases(corplot_data),]
colors = c('HC' = '#ffeda0', 'CHR' = '#feb24c', 'FEP' = '#f03b20')


windowsFonts(Calibri = windowsFont("Calibri"))
g = ggplot(data = corplot_data, aes(x=PANSS, y=param))+
  geom_point(alpha=.95, size = 3) +
  ylab(expression(bold(m[bold("3")]))) +
  xlab('PANSS Positive') +
  geom_smooth(method = lm, formula = y~x) +
  theme_classic()+
  theme(text = element_text (family = "Calibri", size = 30, face = 'bold'),
        legend.position = c(0.7, 0.15), legend.title=element_blank())
g

ggsave(paste0(root_save, 'correlation_m3_panss_p.png'), g,
       width = 5, height = 5, dpi = 300)


# PANSS N and kappa2
corplot_data = data.frame(PANSS_N,params$ka_2, group)
colnames(corplot_data) = c('PANSS', 'param', 'group')
corplot_data = corplot_data[complete.cases(corplot_data),]

windowsFonts(Calibri = windowsFont("Calibri"))
g = ggplot(data = corplot_data, aes(x=PANSS, y=param))+
  geom_point(alpha=.95, size = 3) +
  ylab(expression(bold(kappa[bold("2")]))) +
  xlab('PANSS Negative') +
  scale_y_continuous(limits=c(.3, .6)) + # This excludes outlier subject from plot (comment out if you wish to see it)
  geom_smooth(method = lm, formula = y~x) +
  theme_classic()+
  theme(text = element_text (family = "Calibri", size = 30, face = 'bold'),
        legend.position = c(0.8, 0.8), legend.title=element_blank())
g

ggsave(paste0(root_save, 'correlation_kappa_panss_n.png'), g,
       width = 5, height = 5, dpi = 300)


# PANSS G and kappa2
corplot_data = data.frame(PANSS_G,params$ka_2)
colnames(corplot_data) = c('PANSS', 'param')
corplot_data = corplot_data[complete.cases(corplot_data),]

windowsFonts(Calibri = windowsFont("Calibri"))
g = ggplot(data = corplot_data, aes(x=PANSS, y=param))+
  geom_point(alpha=.95, size = 3) +
  ylab(expression(bold(kappa[bold("2")]))) +
  xlab('PANSS General') +
  scale_y_continuous(limits=c(.3, .6)) + # This excludes outlier subject from plot (comment out if you wish to see it)
  geom_smooth(method = lm, formula = y~x) +
  theme_classic()+
  theme(text = element_text (family = "Calibri", size = 30, face = 'bold'),
        legend.position = c(0.1, 0.28), legend.title=element_blank())
g

ggsave(paste0(root_save, 'correlation_kappa_panss_g.png'), g,
       width = 5, height = 5, dpi = 300)



#--------------------------------
# PCL-parameter correlations
#--------------------------------
n.params = dim(params)[2]
n.symptoms = dim(pcl)[2]
n.comp = n.params * n.symptoms

p = vector(mode = 'numeric', length = n.comp)
tau = vector(mode = 'numeric', length = n.comp)
parameter = vector(mode = 'character', length = n.comp)
symptom = vector(mode = 'character', length = n.comp)

c = 1
for (i in 1:n.params){
  cat(paste0('\n---------------------\n ', colnames(params)[i], '\n---------------------'))
  for (j in 1:n.symptoms){
    cat(paste0('\n---------------------\n ',colnames(pcl)[j], '\n---------------------\n'))
    res = cor.test(pcl[,j], params[,i], method ="kendall")
    # res = kruskal.test(Y[,j] ~ m_3)
    p[c] = res$p.value
    tau[c] = res$estimate
    parameter[c] = colnames(params)[i]
    symptom[c] = colnames(pcl)[j]
    print(res)
    c = c+1
  }
}

# Summarize results
p.fdr =  p.adjust(p, method = 'fdr')
p.bf =  p.adjust(p, method = 'bonferroni')
sign = as.numeric(p < 0.05)
sign.fdr = as.numeric(p.fdr < 0.05)
sign.bf = as.numeric(p.bf < 0.05)

cat(paste0('\n---------------------------\nSummary\n---------------------------'))
print(data.frame(parameter, symptom, tau, p, p.fdr, p.bf, sign, sign.fdr, sign.bf), row.names = F)



#--------------------------------
# Plots raw data
#--------------------------------
corplot_data = data.frame(pcl_freq, params$m_3, group)
corplot_data = corplot_data[complete.cases(corplot_data),]
colnames(corplot_data) = c('pcl_freq', 'm3', 'group')
colors = c('HC' = '#ffeda0', 'CHR' = '#feb24c', 'FEP' = '#f03b20')


windowsFonts(Calibri = windowsFont("Calibri"))
g = ggplot(data = corplot_data, aes(x=pcl_freq, y=m3))+
  geom_point(alpha=.95, size = 3) +
  ylab(expression(bold(m[bold("3")]))) +
  xlab('PCL Frequency') +
  geom_smooth(method = lm, formula = y~x) +
  theme_classic()+
  theme(text = element_text (family = "Calibri", size = 30, face = 'bold'),
        legend.position = c(0.7, 0.15), legend.title=element_blank())
g

ggsave(paste0(root_save, 'correlation_m3_plc_freq.png'), g,
       width = 5, height = 5, dpi = 300)

