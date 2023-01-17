################################################################################
# Source code for plotting results in Figure 1-4
# Date of this version: 2023-01-17
# of the paper:
#          "	A gender perspective on the global migration of scholars "
#
# CITATION: XXXXXXXXXXXXXXXXXX
# DOI: XXXXXXXXXXXX
#
# Author of the code: Xinyi Zhao
# ORCID: 0000-0002-2552-7795
# Institution1: Max Planck Institute for Demographic Research, Rostock, Germany
# Institution2: Leverhulme Centre for Demographic Science, Department of
#               Sociology, University of Oxford, Oxford, UK
# WWW: https://www.demogr.mpg.de/en/about_us_6113/staff_directory_1899/xinyi_zhao_4083/
# WWW2: xxxxxxx
# Email: zhao@demogr.mpg.de
# Email2: xinyi.zhao@st-hughs.ox.ac.uk
################################################################################

# for path to be relative to current directory
library(here)
current_path = here("..")
# If you use R in VScode and similar, put "here()" that will be the directory one level above the current script. In RStudio, use as above "here("..")"

# set working directory based on this script's location
setwd(current_path)
# getwd() to check

# data URL
data_dir = here("For_figure_1_3_R")
figures_dir = here("figures")

# install ggflags using devtools 
# 1) install.packages('devtools')
# 2) devtools::install_github('rensa/ggflags')

# install and load other needed packages:
# use "install.packages(c("PACKAGE1", "PACKAGE2"))" for all not currently installed
library(ggflags)
library(plotly)
library(ggplot2)
library(scales)
library(tidyverse)
library(ggpmisc)
library(magrittr)
library(dplyr)
library(ggh4x)
library(rlang)
library(grid)
library(gridExtra)
library(viridis)
library(patchwork)
library(hrbrthemes)
library(circlize)
library(alluvial)
library(ggalluvial)
library("readxl")
library(RColorBrewer)

################################################################################
# Figure 1:
# Gender ratios among all published researchers (X-axis) VS migrant researchers (Y-axis)
################################################################################

# read file:
gender_ratio_ctr <-
  read.csv(file = here(data_dir, '1_aggregated_country_level_migrant.csv')) %>% mutate_all(na_if, "")

gender_ratio_ctr$iso2 <- tolower(gender_ratio_ctr$iso2)


# select the countries with over 500 female migrants each period
gender_ratio <-
  gender_ratio_ctr %>% filter(female_migrant_count >= 500)

# set the color corronding to different countries
residenceCountry <-
  c(
    "China",
    "France",
    "Germany",
    "Italy",
    "Japan",
    "Spain",
    "United Kingdom",
    "United States",
    "South Korea",
    "Brazil",
    "Argentina",
    "Portugal"
  )
color <-
  c(
    "#F70101",
    "#0050a4",
    "#FFCC00",
    "#008C45",
    "#ffafcc",
    "#FF7F11",
    "#A234EB",
    "#B22234",
    "#65D6C1",
    "#012169",
    "#75AADB",
    "#FF602B"
  )

setting <- data.frame(residenceCountry, color)
setting$shape <- 16

gender_ratio <-
  merge(gender_ratio,
        setting,
        by = "residenceCountry",
        all.x = TRUE)


# related display format setting
gender_ratio$color[is.na(gender_ratio$color)] <- "#6c757d"
gender_ratio$shape[is.na(gender_ratio$shape)] <- 1

gender_ratio$size <- gender_ratio$female_migrant_count / 200
gender_ratio$size[gender_ratio$size < 10] <- 10

plot_list <- list()
output_path_pdf <-
  here(figures_dir, "1_gender_ratio_scatter.pdf")

pdf(output_path_pdf,  width = 15, height = 15)
for (f in unique(gender_ratio$period)) {
  gender_ratio_p <-
    gender_ratio %>% filter(period == f) %>% arrange(shape, desc(migrant_count)) %>%
    mutate(size_scale = rescale(size, to = c(4, 15)))
  
  plot_list[[f]] <-
    ggplot(gender_ratio_p,
           aes(x = gender_ratio_all, y = gender_ratio_migrant)) +
    xlim(0, 1.2) +
    ylim(0, 1.2) +
    labs(x = "Gender ratios among all researchers") +
    labs(y = "Gender ratios \n among migrant researchers") +
    labs(title = paste("Period :", {
      {
        gender_ratio_p$period
      }
    })) +
    geom_abline(
      intercept = 0,
      slope = 1,
      linetype = 1,
      color = "#dde5b6",
      size = 1
    ) +
    geom_smooth(
      formula = y ~ x,
      method = "lm",
      linetype = 1,
      size = 1.2,
      fullrange = TRUE,
      color = "#98c1d9"
    ) +
    geom_vline(
      xintercept = median(gender_ratio_p$gender_ratio_all),
      linetype = "dashed",
      color = "grey",
      size = 1.2
    ) +
    geom_hline(
      yintercept = median(gender_ratio_p$gender_ratio_migrant),
      linetype = "dashed",
      color = "grey",
      size = 1.2
    ) +
    #geom_abline(intercept = round(coeff[1],1), slope = round(coeff[2],1), color="blue",
    #            linetype="dotted", size=1.2)+
    geom_point(
      colour = gender_ratio_p$color,
      size = gender_ratio_p$size_scale,
      shape = gender_ratio_p$shape
    ) +
    scale_size(range = c(0, 15)) +
    theme_bw() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 20),
      axis.text = element_text(size = 14),
      axis.title = element_text(size = 16)
    )
  
  
  #,country=iso2,size=size_scale,show.legend = FALSE
  
}
grid.arrange(grobs = plot_list, ncol = 2)
dev.off()

### Note on Figure 1
# Replication script will generate the figures as presented in the manuscript. 
# But, a few labels and annotations are added afterwards to clarify the most 
# important information and serve an aesthetic purpose without changing 
# any underlying data or results.

################################################################################
# Figure 2:
# Gender ratios among all published researchers (X-axis) VS migrant researchers (Y-axis)
################################################################################

# read files:
country_spread <-
  read.csv(file = here(data_dir, "2_country_level_spread.csv"))
country_spread$iso2 <- tolower(country_spread$iso2)
global_spread <-
  read.csv(file = here(data_dir, "2_global_spread_withweighted.csv"))



# select specific countries in figure
country_selected <-
  c("United States",
    "Germany",
    "Italy",
    "Brazil",
    "China",
    "South Korea")

country_spread_selected <-
  country_spread[country_spread$residenceCountry %in% country_selected ,]

output_path_pdf <- here(figures_dir, "2_migration_spread.pdf")
pdf(output_path_pdf,  width = 28, height = 14)
plot_list <- list()
plot_list[[1]] <- ggplot(NULL)
plot_list[[2]] <- ggplot(NULL)


plot_list[[1]] <-
  plot_list[[1]] + geom_line(
    data = global_spread,
    aes(x = period, y = ES_global_female_weighted),
    linetype = "solid",
    color = "#ffb703",
    size = 2,
    show.legend = FALSE
  ) +
  geom_point(
    data = global_spread,
    aes(x = period, y = ES_global_female_weighted),
    shape = 19,
    color = "#ffb703",
    size = 10
  ) +
  
  geom_line(
    data = global_spread,
    aes(x = period, y = ES_global_male_weighted),
    linetype = "solid",
    color = "#8ecae6",
    size = 2,
    show.legend = FALSE
  ) +
  geom_point(
    data = global_spread,
    aes(x = period, y = ES_global_male_weighted),
    shape = 19,
    color = "#8ecae6",
    size = 10
  )


plot_list[[2]] <-
  plot_list[[2]] + geom_line(
    data = global_spread,
    aes(x = period, y = IS_global_female_weighted),
    linetype = "solid",
    color = "#ffb703",
    size = 2
  ) +
  geom_point(
    data = global_spread,
    aes(x = period, y = IS_global_female_weighted),
    shape = 19,
    color = "#ffb703",
    size = 10
  ) +
  
  geom_line(
    data = global_spread,
    aes(x = period, y = IS_global_male_weighted),
    linetype = "solid",
    color = "#8ecae6",
    size = 2
  ) +
  geom_point(
    data = global_spread,
    aes(x = period, y = IS_global_male_weighted),
    shape = 19,
    color = "#8ecae6",
    size = 10
  )

for (c in unique(country_spread_selected$residenceCountry)) {
  country_selected_c <-
    country_spread_selected %>% filter(residenceCountry == c)
  
  
  
  plot_list[[1]] <-
    plot_list[[1]] + geom_line(
      data = country_selected_c,
      aes(x = period, y = ES_ctr_female, color = "#fb8500"),
      linetype = "solid",
      size = 2,
      show.legend = FALSE
    ) +
    geom_flag(data = country_selected_c,
              aes(x = period, y = ES_ctr_female, country = iso2),
              size = 10) +
    geom_line(
      data = country_selected_c,
      aes(x = period, y = ES_ctr_male, color = "#219ebc"),
      linetype = "solid",
      size = 2,
      show.legend = FALSE
    ) +
    geom_flag(data = country_selected_c,
              aes(x = period, y = ES_ctr_male, country = iso2),
              size = 10)
  
  plot_list[[2]] <-
    plot_list[[2]] + geom_line(
      data = country_selected_c,
      aes(x = period, y = IS_ctr_female, color = "#fb8500"),
      linetype = "solid",
      size = 2,
      show.legend = FALSE
    ) +
    geom_flag(data = country_selected_c,
              aes(x = period, y = IS_ctr_female, country = iso2),
              size = 10) +
    
    geom_line(
      data = country_selected_c,
      aes(x = period, y = IS_ctr_male, color = "#219ebc"),
      linetype = "solid",
      size = 2,
      show.legend = FALSE
    ) +
    geom_flag(data = country_selected_c,
              aes(x = period, y = IS_ctr_male, country = iso2),
              size = 10)
  
}

plot_list[[1]] <- plot_list[[1]] +
  ggtitle("Emigration") +
  labs(x = "Period") +
  scale_x_continuous(breaks = 1:4,
                     labels = paste0(c(
                       "1998-2002", "2003-2007", "2008-2012", "2013-2017"
                     ))) +
  labs(y = "Spread Level") +
  labs(color = "Legend") +
  scale_shape_identity() +
  scale_color_identity() +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 32),
    axis.text.y = element_text(size = 30),
    axis.text.x = element_text(size = 24),
    axis.title = element_text(size = 32)
  )



plot_list[[2]] <- plot_list[[2]] +
  ggtitle("Immigration") +
  labs(y = " ") +
  labs(x = "Period") +
  scale_x_continuous(breaks = 1:4,
                     labels = paste0(c(
                       "1998-2002", "2003-2007", "2008-2012", "2013-2017"
                     ))) +
  labs(color = "Legend") +
  scale_shape_identity() +
  scale_color_identity() +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 32),
    axis.text.y = element_blank(),
    axis.text.x = element_text(size = 24),
    axis.title = element_text(size = 32)
  )


grid.arrange(grobs = plot_list, ncol = 2)

dev.off()

### Note on Figure 2
# Replication script will generate the figures as presented in the manuscript. 
# But, a few labels and annotations are added afterwards to clarify the most 
# important information and serve an aesthetic purpose without changing 
# any underlying data or results.

################################################################################
# Figure 3:
# The 10 most preferred destinations for global mobile researchers by gender
# Note: 
# The aesthetics of the labels are proposed after the production of figures
################################################################################

# proposed top destinations for data visualization 
female_D <-
  read_excel(
    here(data_dir, '3_female_preferred_D_global_top12.xlsx')
  )
male_D <-
  read_excel(
    here(data_dir, '3_male_preferred_D_global_top13.xlsx')
  )

# set the colors for different countries
nb.cols <- 14
mycolors <- colorRampPalette(brewer.pal(8, "Set2"))(nb.cols)
mycolors <-
  c(
    "#AEC3B0",
    "#9681B3",
    "#B8DE7C",
    "#87B9DA",
    "#1A73AF",
    "#F48942",
    "#6D9E1E",
    "#ffb55a",
    "#FAC19C",
    "#beb9db",
    "#D5E2F0",
    "#0050A4",
    "#6B4C93",
    "#FFCA3A",
    "#E9F5D7"
  )
residenceCountry <-
  c(
    "Australia",
    "Canada",
    "China",
    "France",
    "Germany",
    "Italy",
    "Japan",
    "Netherlands",
    "Spain",
    "Sweden",
    "Switzerland",
    "United Kingdom",
    "United States",
    "India",
    "South Korea"
  )
ctr_col <- data.frame(residenceCountry, mycolors)
names(ctr_col) <- c("residenceCountry", "col")

#sort values
female_D <- female_D %>% arrange(desc(female))
female_D <- merge(female_D, ctr_col, by = "residenceCountry")

output_path_pdf <-
  here(figures_dir, "3_global_female_destination.pdf")
pdf(output_path_pdf,  width = 14, height = 8)

gg <- ggplot(data = female_D,
             aes(x = period, y = female, alluvium = residenceCountry)) +
  theme_bw() +
  ylab(NULL) +
  xlab(NULL) +
  theme(
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank(),
    axis.text.y = element_blank(),
    axis.text.x = element_text(size = 14),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    legend.position = "none"
  ) +
  
  scale_fill_manual(values = mycolors)

# proportional knot positioning (default)
gg +
  geom_alluvium(
    aes(fill = residenceCountry),
    alpha = .75,
    decreasing = FALSE,
    width = 1 / 2
  ) +
  geom_stratum(
    aes(stratum = residenceCountry, fill = residenceCountry),
    color = "white",
    decreasing = FALSE,
    width = 1 / 2
  )

dev.off()


#sort values
male_D <- male_D %>% arrange(desc(male))
male_D <- merge(male_D, ctr_col, by = "residenceCountry")

#assign colors to countries
col <- as.character(ctr_col$col)
names(col) <- as.character(ctr_col$residenceCountry)


output_path_pdf <-
  here(figures_dir, "3_global_male_destination.pdf")
pdf(output_path_pdf,  width = 14, height = 8)

gg <- ggplot(data = male_D,
             aes(x = period, y = male, alluvium = residenceCountry)) +
  theme_bw() +
  ylab(NULL) +
  xlab(NULL) +
  theme(
    axis.ticks.x = element_blank(),
    axis.ticks.y = element_blank(),
    axis.text.y = element_blank(),
    axis.text.x = element_text(size = 14),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    legend.position = "none"
  ) +
  scale_fill_manual(values = col)

# proportional knot positioning (default)
gg +
  geom_alluvium(
    aes(fill = residenceCountry),
    alpha = .75,
    decreasing = FALSE,
    width = 1 / 2
  ) +
  geom_stratum(
    aes(stratum = residenceCountry, fill = residenceCountry),
    color = "white",
    decreasing = FALSE,
    width = 1 / 2
  )

dev.off()

### Note on Figure 3
# Replication script will generate the figures as presented in the manuscript. 
# But, a few labels and annotations are added afterwards to clarify the most 
# important information and serve an aesthetic purpose without changing 
# any underlying data or results.

################################################################################
# Figure 4:
# Top three destinations for mobile researchers by gender at the country level
# Note: 
# The aesthetics of the labels are proposed after the production of figures
################################################################################
female_D_ctr <-read_excel(here(data_dir, '4_female_preferred_D_ctr.xlsx'))
male_D_ctr <- read_excel(here(data_dir, '4_male_preferred_D_ctr.xlsx'))

female_D_ctr <-
  female_D_ctr %>% select(from, to, period, period_year, female_prop, d_order) %>%
  mutate(gender = "female")
names(female_D_ctr) <-
  c("from",
    "to",
    "period",
    "year",
    "proportion",
    "d_order",
    "gender")
male_D_ctr <-
  male_D_ctr %>% select(from, to, period, period_year, male_prop, d_order) %>%
  mutate(gender = "male")
names(male_D_ctr) <-
  c("from",
    "to",
    "period",
    "year",
    "proportion",
    "d_order",
    "gender")

d_ctr <- rbind(female_D_ctr, male_D_ctr)
country_selected <-
  c("United States",
    "Germany",
    "Brazil",
    "Italy",
    "China",
    "South Korea")



# new color assignment
mycolors <-
  c(
    "#aec3b0",
    "#9681b3",
    "#b8de7c",
    "#99b9da",
    "#3e73ae",
    "#F48942",
    "#6d9e1e",
    "#ffb55a",
    "#FAC19C",
    "#beb9db",
    "#d5e2f0",
    "#0050a4",
    "#6a4cae",
    "#ffca3a",
    "#E9F5D7",
    "#dff5d7",
    "#FEDD00",
    "#b2f7ef"
  )
residenceCountry <-
  c(
    "Australia",
    "Canada",
    "China",
    "France",
    "Germany",
    "Italy",
    "Japan",
    "Netherlands",
    "Spain",
    "Sweden",
    "Switzerland",
    "United Kingdom",
    "United States",
    "India",
    "South Korea",
    "Singapore",
    "Brazil",
    "Israel"
  )
ctr_col <- data.frame(residenceCountry, mycolors)



names(ctr_col) <- c("to", "col")

d_ctr <- merge(d_ctr, ctr_col, by = "to")


output_path_pdf <- here(figures_dir, "4_top_three_destinations.pdf")

pdf(output_path_pdf,  width = 16, height = 8)

plot_list <- list()
i = 1
for (c in country_selected) {
  d_ctr_c <- d_ctr %>% filter(from == c) %>% arrange(period, gender, d_order)
  
  #*** reorder very important
  plot_list[[i]] <- ggplot(d_ctr_c, aes(x = gender, y = proportion)) +
    geom_bar(
      stat = 'identity',
      position = 'stack',
      fill = reorder(d_ctr_c$col, -d_ctr_c$d_order)
    ) + facet_grid( ~ year) +
    #scale_fill_manual(name="Country",values = mycolors)+
    labs(x = d_ctr_c$from) +
    scale_y_continuous(limits = c(0, 0.9)) +
    theme_bw() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 24),
      axis.text.x = element_text(size = 12),
      axis.text.y = element_text(size = 14),
      axis.title.x = element_text(size = 16),
      axis.title.y = element_text(size = 16),
      strip.text = element_text(size = 14),
      strip.background = element_rect(fill = "white")
      
    ) +
    theme(legend.title = element_text(size = 16),
          #change legend title font size
          legend.text = element_text(size = 14)) #change legend text font size
  
  i = i + 1
  
  
}

grid.arrange(grobs = plot_list, nrow = 2, ncol = 3)
dev.off()

while (!is.null(dev.list()))
  dev.off()

### Note on Figure 4
# Replication script will generate the figures as presented in the manuscript. 
# But, a few labels and annotations are added afterwards to clarify the most 
# important information and serve an aesthetic purpose without changing 
# any underlying data or results.