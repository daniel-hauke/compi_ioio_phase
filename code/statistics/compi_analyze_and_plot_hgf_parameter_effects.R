#-------------------------------------------------------------------------------
# This script analyzes and plots group effects on model parameters of the mean-
# reverting model that includes a drift at the third level.
#-------------------------------------------------------------------------------
#---------------------------------------
# Load Packages
#---------------------------------------
# Uncomment next line to install package manager, if needed
#install.packages('pacman')

pacman::p_load(xlsx,
               ggplot2,
               latex2exp,
               gridExtra)

#---------------------------------------
# Load data
#---------------------------------------
# Adapt project root to the project root on your computer
#root_project = 'C:/projects/compi_ioio_phase/'
root_project = 'C:/Users/danie/Desktop/compi_ioio_phase/'

# Get data roots and save directory
root_data = paste0(root_project, 'results/diag_hgf/ms1/m3/')
root_save = paste0(root_project, 'results/figures_paper/')

# Define file names
file_name = 'hgf_parameters'

# Load choice data
temp = read.xlsx(paste0(root_data, file_name,'.xlsx'),
                     as.data.frame = T, 
                     header = T,
                     sheetIndex = 1)

# Prepare data
subjects = as.factor(temp [,1])
group = factor(temp [,2],
               levels = c('HC','CHR','FEP'),
               labels = c('HC','CHR-P','FEP'))

# Create data frame
Y = data.frame(temp[,9:dim(temp)[2]])

# Run some checks
head(Y)
n.params = dim(Y)[2]


#---------------------------------------
# Plot parameter histograms
#---------------------------------------
for (i in 1:n.params){
        hist(Y[,i], main = colnames(Y)[i])
}



#---------------------------------------
# Investigate kappa outlier
#---------------------------------------
# Calulate IQR for outlier
iqr = quantile(Y$ka_2)[4] - quantile(Y$ka_2)[2]
(quantile(Y$ka_2)[3]-min(Y$ka_2))/iqr

# Remove outlier subject (uncommenting the following two line runs the analysis 
# without the extreme kappa value)

# group = group[!(Y$ka_2==min(Y$ka_2))]
# Y = Y[!(Y$ka_2==min(Y$ka_2)),]


#---------------------------------------
# Kruskal Wallis Tests
#---------------------------------------
p = vector(mode = 'numeric', length=n.params)
eta_squared = vector(mode = 'numeric', length=n.params)

# Cycle through parameters
for (i in 1:n.params){
        cat(paste0('\n----------------------\n', colnames(Y)[i], '\n----------------------'))
        res = kruskal.test(Y[,i] ~ group)
        p[i]= res$p.value
        eta_squared[i] = res$statistic/(dim(Y)[1]-1)
        print(res)
}

# Summarize results
p_bon = p.adjust(p, method = 'bonferroni')
p_fdr = p.adjust(p, method = 'fdr')
data.frame(colnames(Y), eta_squared, p, p_fdr, p_bon)
cat('>0.02 small, >.13 medium, >.26 large')


#---------------------------------------
# Posthoc Tests
#---------------------------------------
# Drift attractor point m_3
param = 'm_3'
idx = colnames(Y) == param
n.groups = length(levels(group))
p = vector(mode = 'numeric', length=n.groups)
eta_squared = vector(mode = 'numeric', length=n.groups)
excluded_group = vector(mode ='character', length=n.groups)

for (i in 1:n.groups){
        excluded_group[i] = levels(group)[i]
        res = kruskal.test(Y[group!=excluded_group[i],idx] ~ group[group!=excluded_group[i]])
        p[i]= res$p.value
        eta_squared[i] = res$statistic/(dim(Y[group!=excluded_group[i],])[1]-1)
        #print(res)
}

# Summarize results
p_bon = p.adjust(p,method = 'bonferroni')
p_fdr = p.adjust(p,method = 'fdr')

cat(paste0('\n----------------------\n', colnames(Y)[idx], '\n----------------------'))
data.frame(excluded_group, eta_squared, p, p_fdr, p_bon)
cat('>0.02 small, >.13 medium, >.26 large')     


# Coupling strength between hierarchical levels ka_2
param = 'ka_2'
idx = colnames(Y) == param
n.groups = length(levels(group))
p = vector(mode = 'numeric', length=n.groups)
eta_squared = vector(mode = 'numeric', length=n.groups)
excluded_group = vector(mode ='character', length=n.groups)

for (i in 1:n.groups){
        excluded_group[i] = levels(group)[i]
        res = kruskal.test(Y[group!=excluded_group[i],idx] ~ group[group!=excluded_group[i]])
        p[i]= res$p.value
        eta_squared[i] = res$statistic/(dim(Y[group!=excluded_group[i],])[1]-1)
        #print(res)
}

# Summarize results
p_bon = p.adjust(p,method = 'bonferroni')
p_fdr = p.adjust(p,method = 'fdr')

cat(paste0('\n----------------------\n', colnames(Y)[idx], '\n----------------------'))
data.frame(excluded_group, eta_squared, p, p_fdr, p_bon)
cat('>0.02 small, >.13 medium, >.26 large') 


#---------------------------------------
# Plot m3
#---------------------------------------
param = 'm_3'
idx = colnames(Y) == param
data = data.frame(Y[,idx], group)
colnames(data) = c('param', 'group')

# Get range of parameter for adjusting axes
range.param = range(data$param) 
range.dif = range.param[2]-range.param[1]

# Get group means
summary = data.frame(levels(data$group),
                     c(mean(data$param[data$group == 'HC']),
                       mean(data$param[data$group == 'CHR-P']),
                       mean(data$param[data$group == 'FEP'])))
colnames(summary) = c('group', 'param')

# Set colors and font
colors = c('HC' = '#ffeda0', 'CHR-P' = '#feb24c', 'FEP' = '#f03b20')
colors = c('HC' = '#fe9929', 'CHR-P' = '#d95f0e', 'FEP' = '#993404') 
windowsFonts(Calibri = windowsFont("Calibri"))

# Plot left
g.left = ggplot(data = data) +
        geom_density(aes(x = param, y=..density.., color = group),
                     alpha = .2,
                     size = 1) +
        scale_color_manual(values=colors) +
        scale_x_continuous(limits = c(min(Y[,i])-.05*range.dif, max(Y[,i])+.05*range.dif), breaks = seq(0, 3, by = .5)) +
        # Axis
        ylab('Density') +
        xlab(expression(bold(m[bold("3")]))) +
        coord_flip() +
        theme_linedraw() +
        theme(text = element_text (family = "Calibri", size = 30, face = 'bold'),
              legend.position="none",
              axis.title.y = element_text(margin = margin(t = 0, r = 0, b = 0, l = 0)),
              axis.title.x = element_text(margin = margin(t = 4, r = 0, b = 0, l = 0)),
              axis.text.y = element_text(),
              axis.text.x = element_blank(),
              panel.grid.major =  element_blank(),
              panel.grid.minor =  element_blank())
g.left

# Plot right
h1 = 2.95
set.seed(555) # to fix jitter
g.right = ggplot(data, aes(x = group, y = param, fill = group)) +
        geom_boxplot(outlier.shape = NA, fatten = 4 )+
        scale_fill_manual(values = colors) +
        geom_jitter(position = position_jitterdodge(dodge.width = 0.75, jitter.width = .75), alpha = .3, size = 3.5) +
        scale_y_continuous(limits = c(min(Y[,i])-.05*range.dif, max(Y[,i])+.05*range.dif), breaks = NULL) +
        geom_point(data = summary, size = 5, shape = 22, position = position_dodge(width=0.75), show.legend = F) +
        scale_shape_identity() +
        theme_linedraw() +
        theme(text = element_text (family = "Calibri", size = 25, face = 'bold'),
              legend.position="none",
              axis.title.x=element_blank(),
              axis.title.y=element_blank(),
              axis.text.y = element_blank(),
              axis.text.x = element_text(size = 25, margin = margin(t = 7.5, r = 0, b = 0, l = 0)),
              panel.grid.major.x =  element_blank()) +
        # Effects
        geom_segment(aes(x = 1, y = h1, xend = 3, yend = h1)) +
        annotate("text", x = 2, y = h1 + .005, label = "*", size = 15)

g.right 

# Create multiplot
grid.arrange(g.left, g.right, ncol = 2, widths = c(.45, .55)) 
g <- arrangeGrob(g.left, g.right, ncol = 2, widths = c(.45, .55)) 
ggsave(paste0(root_save, 'hgf_parameter_effect_m3.png'), g,
       width = 5, height = 6, dpi = 300)


#---------------------------------------------
# Plot kappa
#---------------------------------------------
param = 'ka_2'
idx = colnames(Y) == param
data = data.frame(Y[,idx], group)
colnames(data) = c('param', 'group')

# Get range of parameter for adjusting axes
range.param = range(data$param)
range.dif = range.param[2]-range.param[1]

# Get group means
summary = data.frame(levels(data$group),
                     c(mean(data$param[data$group == 'HC']),
                       mean(data$param[data$group == 'CHR-P']),
                       mean(data$param[data$group == 'FEP'])))
colnames(summary) = c('group', 'param')

# Set colors and font
colors = c('HC' = '#ffeda0', 'CHR-P' = '#feb24c', 'FEP' = '#f03b20')
colors = c('HC' = '#fe9929', 'CHR-P' = '#d95f0e', 'FEP' = '#993404') 
windowsFonts(Calibri = windowsFont("Calibri"))

# Plot left
g.left = ggplot(data = data) +
        geom_density(aes(x = param, y=..density.., color = group),
                     alpha = .2,
                     size = 1) +
        scale_color_manual(values=colors) +
        scale_x_continuous(limits = c(.3, range.param[2]+.05*range.dif), breaks = seq(0.3, .6, by = .1)) +
        # Note, that outlier kappa was removed from plot (comment next line out to see full plot)
        # scale_x_continuous(limits = c(min(Y[,i])-.05*range.dif, max(Y[,i])+.05*range.dif), breaks = seq(0, 3, by = .5)) +
        ylab('Density') +
        xlab(expression(bold(kappa[bold("2")]))) +
        coord_flip() +
        theme_linedraw() +
        theme(text = element_text (family = "Calibri", size = 30, face = 'bold'),
              legend.position="none",
              axis.title.y = element_text(margin = margin(t = 0, r = 0, b = 0, l = 0)),
              axis.title.x = element_text(margin = margin(t = 4, r = 0, b = 0, l = 0)),
              axis.text.y = element_text(),
              axis.text.x = element_blank(),
              panel.grid.major =  element_blank(),
              panel.grid.minor =  element_blank())
g.left

h1 = .58
set.seed(555) # to fix jitter
g.right = ggplot(data, aes(x = group, y = param, fill = group)) +
        geom_boxplot(outlier.shape = NA, fatten = 4)+
        scale_fill_manual(values = colors) +
        geom_jitter(position = position_jitterdodge(dodge.width = 0.75, jitter.width = .75), alpha = .3, size = 3.5) +
        scale_y_continuous(limits = c(.3, range.param[2]+.05*range.dif), breaks = NULL) +
        # Note, that outlier kappa was removed from plot (comment next line out to see full plot)
        # scale_y_continuous(limits = c(min(Y[,i])-.05*range.dif, max(Y[,i])+.05*range.dif), breaks = seq(0, 3, by = .5)) +
        geom_point(data = summary, size = 5, shape = 22, position = position_dodge(width=0.75), show.legend = F) +
        scale_shape_identity() +
        theme_linedraw() +
        theme(text = element_text (family = "Calibri", size = 25, face = 'bold'),
              legend.position="none",
              axis.title.x=element_blank(),
              axis.title.y=element_blank(),
              axis.text.y = element_blank(),
              axis.text.x = element_text(size = 25, margin = margin(t = 7.5, r = 0, b = 0, l = 0)),
              panel.grid.major.x =  element_blank()) +
        # Effects
        geom_segment(aes(x = 1, y = h1, xend = 3, yend = h1)) +
        annotate("text", x = 2, y = h1 + .005, label = "*", size = 15)

g.right 

grid.arrange(g.left,g.right, ncol = 2, widths = c(.45, .55)) 
g <- arrangeGrob(g.left,g.right, ncol = 2, widths = c(.45, .55)) 
ggsave(paste0(root_save, 'hgf_parameter_effect_kappa.png'), g,
       width = 5, height = 6, dpi = 300)


