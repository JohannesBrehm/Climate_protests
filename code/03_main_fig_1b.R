################################################################################
# FIGURE 1B: CLIMATE CHANGE CONCERN & GOOGLE TRENDS
################################################################################

# necessary libraries
library(haven)
library(ggplot2)
library(patchwork)

# set working directory
setwd("C:// INSERT YOUR PATH HERE")

### GOOGLE TRENDS ##############################################################

# read dataset
trends <- read_dta("google_trends_fff_eg_xr.dta")

# compile figure
trends_plot <- ggplot(trends, aes(x=week_count)) +
  # general design
  theme(axis.title.x = element_text(family="serif", size = 12, margin = margin(t=10)),
        axis.line.x = element_line(color ='black'),
        axis.title.y = element_text(family="serif", size = 12, margin = margin(r=15)),
        axis.line.y = element_line(color ='black'),
        axis.title.y.right = element_text(angle=90, vjust=0.5),
        panel.background = element_rect(fill='white'),
        legend.title = element_text(hjust = 0.5, family = "serif", size = 12), legend.text = element_text(family="serif", size = 12), legend.position = "bottom", legend.key = element_rect(fill = "white"),
        plot.margin = unit(c(0,2,1,1), "pt")) +
        guides(color = guide_legend(title = "Protest movement", title.position = "top")) +
  # axes
  labs(y="Google Trends", x=element_blank()) +
  scale_x_continuous(breaks = seq(1, 261, by = 52), labels=c("1" = "2016", "53" = "2017", "105" = "2018", "157" = "2019", "209" = "2020", "261" = "2021"), position = "bottom") +
  scale_y_continuous(position = "right") +
  # add EG time series
  geom_line(aes(y=eg, color = "EG"), linewidth = 0.75) +
  # add XR time series
  geom_line(aes(y=xr, color = "XR"), linewidth = 0.75) +
  # add FfF time series
  geom_line(aes(y=fff, color = "FfF"), linewidth = 0.75) +
  # define values, protests design
  scale_color_manual(values = c("EG"="darkblue", "FfF"="green", "XR"="steelblue1"), labels = c("Ende Gelände", "Fridays for Future", "Extinction Rebellion"))

# display figure
print(trends_plot)



### CLIMATE CHANGE CONCERN #####################################################

# read dataset
concern <- read_dta("r_input_fig1b.dta")

# restrict window to exclude outliers
concern$agg_climate_concern_week[concern$agg_climate_concern_week > 95] <- NA
concern$agg_climate_concern_week[concern$agg_climate_concern_week < 65] <- NA

# define scale for observation color gradient
obs_breaks <- exp(seq(log(min(1)), log(2352), length = 7))
print(obs_breaks)
color_breaks <- exp(seq(log(1), log(100), length = 7))
print(color_breaks)

# compile figure
concern_plot <- ggplot(concern, aes(x=week, y=agg_climate_concern_week, color = week_count)) +
  # weekly observations
  geom_point(data = subset(concern, week_count >= 1), aes(color = ">0")) +
  geom_point(data = subset(concern, week_count >= 4), aes(color = ">3")) +
  geom_point(data = subset(concern, week_count >= 13), aes(color = ">12")) +
  geom_point(data = subset(concern, week_count >= 48), aes(color = ">47")) +
  geom_point(data = subset(concern, week_count >= 177), aes(color = ">176")) +
  geom_point(data = subset(concern, week_count >= 645), aes(color = ">644")) +
  # axes
  labs(y="Climate Change Concerned Population (%)", x=element_blank()) +
  scale_x_continuous(breaks = seq(2912, 3172, by = 52), labels=c("2912" = "2016", "2964" = "2017", "3016" = "2018", "3068" = "2019", "3120" = "2020", "3172" = "2021"), position = "top") +
  scale_y_continuous(breaks = seq(min(65), max(95), by = 5), labels=c("65"="65", "70"="70", "75"="75", "80"="80", "85"="85", "90"="90", "95"="95")) +
  # general design
  theme(axis.title.x = element_blank(),
        axis.line.x = element_line(color ='black'),
        axis.title.y = element_text(family="serif", size = 12, margin = margin(r=15)), 
        axis.line.y = element_line(color ='black'), 
        axis.title.y.left = element_text(vjust = 0.5),
        panel.background = element_rect(fill='white'),
        legend.title = element_text(hjust = 0.5, family = "serif", size = 12), legend.text = element_text(family="serif", size = 12),  legend.position = "top", legend.key = element_rect(fill = "white"),
        plot.margin = unit(c(1,1,0,1), "pt")) +
        guides(color = guide_legend(override.aes = list(linetype = 0), title = "No. of weekly respondents", title.position = "top")) +
  
  # add EG
  geom_segment(aes(x = 2930, y = 65, xend = 2930, yend = 95, color="EG")) +
  geom_text(aes(x=2930, y=64.5, label="1"), size = 3, colour="black") +
  geom_segment(aes(x = 2930, y = 62, xend = 2930, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 2996, y = 65, xend = 2996, yend = 95, color="EG")) +
  geom_text(aes(x=2996, y=64.5, label="2"), size = 3, colour="black") +
  geom_segment(aes(x = 2996, y = 62, xend = 2996, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 3006, y = 65, xend = 3006, yend = 95, color="EG")) +
  geom_text(aes(x=3006, y=64.5, label="3"), size = 3, colour="black") +
  geom_segment(aes(x = 3006, y = 62, xend = 3006, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 3054, y = 65, xend = 3054, yend = 95, color="EG")) +
  geom_text(aes(x=3054, y=64.5, label="4"), size = 3, colour="black") +
  geom_segment(aes(x = 3054, y = 62, xend = 3054, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 3057, y = 65, xend = 3057, yend = 95, color="EG")) +
  geom_text(aes(x=3057, y=64.5, label="5"), size = 3, colour="black") +
  geom_segment(aes(x = 3057, y = 62, xend = 3057, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 3091, y = 65, xend = 3091, yend = 95, color="EG")) +
  geom_text(aes(x=3091, y=64.5, label="8"), size = 3, colour="black") +
  geom_segment(aes(x = 3091, y = 62, xend = 3091, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 3114, y = 65, xend = 3114, yend = 95, color="EG")) + # 30.11.2019: double event
  geom_text(aes(x=3114, y=64.5, label="11"), size = 3, colour="black") +
  geom_segment(aes(x = 3114, y = 62, xend = 3114, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 3123, y = 65, xend = 3123, yend = 95, color="EG")) +
  geom_text(aes(x=3123, y=64.5, label="12"), size = 3, colour="black") +
  geom_segment(aes(x = 3123, y = 62, xend = 3123, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 3153, y = 65, xend = 3153, yend = 95, color="EG")) +
  geom_text(aes(x=3153, y=64.5, label="15"), size = 3, colour="black") +
  geom_segment(aes(x = 3153, y = 62, xend = 3153, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 3157, y = 65, xend = 3157, yend = 95, color="EG")) + # 23.09.2020: double event
  geom_text(aes(x=3157, y=64.5, label="16"), size = 3, colour="black") +
  geom_segment(aes(x = 3157, y = 62, xend = 3157, yend = 63.75, color="EG")) +
  
  geom_segment(aes(x = 3165, y = 65, xend = 3165, yend = 95, color="EG")) +
  geom_text(aes(x=3165, y=64.5, label="17"), size = 3, colour="black") +
  geom_segment(aes(x = 3165, y = 62, xend = 3165, yend = 63.75, color="EG")) +
  
  #add FfF
  geom_segment(aes(x = 3077, y = 65, xend = 3077, yend = 95, color="FfF")) +
  geom_text(aes(x=3077, y=64.5, label="6"), size = 3, colour="black") +
  geom_segment(aes(x = 3077, y = 62, xend = 3077, yend = 63.75, color="FfF")) +
  
  geom_segment(aes(x = 3087, y = 65, xend = 3087, yend = 95, color="FfF")) +
  geom_text(aes(x=3087, y=64.5, label="7"), size = 3, colour="black") +
  geom_segment(aes(x = 3087, y = 62, xend = 3087, yend = 63.75, color="FfF")) +
  
  geom_segment(aes(x = 3104, y = 65, xend = 3104, yend = 95, color="FfF")) +
  geom_text(aes(x=3104, y=64.5, label="9"), size = 3, colour="black") +
  geom_segment(aes(x = 3104, y = 62, xend = 3104, yend = 63.75, color="FfF")) +
  
  geom_segment(aes(x = 3114, y = 65, xend = 3114, yend = 95, color="FfF"), linetype = "dashed") + # 29.11.2019: double event
  #geom_text(aes(x=3114, y=64.5, label="11"), size = 3, colour="black") +
  geom_segment(aes(x = 3114, y = 62, xend = 3114, yend = 63.75, color="FfF"), linetype = "dashed") +
  
  geom_segment(aes(x = 3135, y = 65, xend = 3135, yend = 95, color="FfF")) +
  geom_text(aes(x=3135, y=64.5, label="13"), size = 3, colour="black") +
  geom_segment(aes(x = 3135, y = 62, xend = 3135, yend = 63.75, color="FfF")) +
  
  geom_segment(aes(x = 3157, y = 65, xend = 3157, yend = 95, color="FfF"), linetype = "dashed") + # 25.09.2020: double event
  #geom_text(aes(x=3157, y=64.5, label="16"), size = 3, colour="black") +
  geom_segment(aes(x = 3157, y = 62, xend = 3157, yend = 63.75, color="FfF"), linetype = "dashed") +
  
  # add XR
  geom_segment(aes(x = 3107, y = 65, xend = 3107, yend = 95, color="XR")) + 
  geom_text(aes(x=3107, y=64.5, label="10"), size = 3, colour="black") +
  geom_segment(aes(x = 3107, y = 62, xend = 3107, yend = 63.75, color="XR")) +
  
  geom_segment(aes(x = 3145, y = 65, xend = 3145, yend = 95, color="XR")) + 
  geom_text(aes(x=3145, y=64.5, label="14"), size = 3, colour="black") +
  geom_segment(aes(x = 3145, y = 62, xend = 3145, yend = 63.75, color="XR")) +
  
  # define values, protests design
  scale_color_manual(values = c("EG"="darkblue", "FfF"="green", "XR"="steelblue1", ">0"="grey98", ">3"="grey95", ">12"="grey90", ">47"="grey78", ">176"="grey54", ">644"="grey0"), breaks = c(">0", ">3", ">12", ">47", ">176", ">644"), labels = c("> 0", "> 3", "> 12", "> 47", "> 176", "> 644")) +
  # add regression line
  geom_smooth(method=lm, se=FALSE, linetype = "dashed", size = 1, color="black")
  
# display figure
print(concern_plot)



### MERGE THE TWO ##############################################################

# plot as one figure
figure1b <- concern_plot + trends_plot + plot_layout(heights =c(2,1), nrow=2)
print(figure1b)

# save final figure
ggsave(plot = figure1b, width = 13, height = 8, device = png, dpi = 1200, filename = "Figure 1b - Climate Change Concern & Google Trends.png", path = "C:\\ INSERT YOUR PATH HERE ")
  