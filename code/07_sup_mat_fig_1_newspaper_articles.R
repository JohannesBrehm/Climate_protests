################################################################################
# SUPPLEMENTARY FIGURE 1 - NEWSPAPER ARTICLES
################################################################################

# necessary libraries
library(ggplot2)
library(lubridate)
library(readtext)
library(dplyr)
library(gridExtra)

# set working directory
setwd("C:// INSERT YOUR PATH HERE")

# retrieve data
  # Fridays for Future
  FFF <- readtext('FfF.docx')
  regex_FFF <- "\\b\\d{1,2} (January|February|March|April|May|June|July|August|September|October|November|December) \\d{4}\\b"
    # dates
    dates_FFF <- regmatches(FFF$text, gregexpr(regex_FFF, FFF$text))[[1]]
    dates_FFF <- parse_date_time(dates_FFF, orders = c("d %B %Y", "d %b %Y"))
    date_table_FFF <- table(dates_FFF)
    date_df_FFF <- data.frame(date = as.Date(names(date_table_FFF), format = "%Y-%m-%d"), 
                          frequency = as.numeric(date_table_FFF))
    # relative frequency like in google trends
    date_df_FFF$relative_frequency <- date_df_FFF$frequency / sum(date_df_FFF$frequency)

  # Ende Gelände
  EG <- readtext('EG.docx')
  regex_EG <- "\\b\\d{1,2} (January|February|March|April|May|June|July|August|September|October|November|December) \\d{4}\\b"
    # dates
    dates_EG <- regmatches(EG$text, gregexpr(regex_EG, EG$text))[[1]]
    dates_EG <- parse_date_time(dates_EG, orders = c("d %B %Y", "d %b %Y"))
    date_table_EG <- table(dates_EG)
    date_df_EG <- data.frame(date = as.Date(names(date_table_EG), format = "%Y-%m-%d"), 
                         frequency = as.numeric(date_table_EG))
    # relative frequency like in google trends
    date_df_EG$relative_frequency <- date_df_EG$frequency / sum(date_df_EG$frequency)

  # Extinction Rebellion
  XR <- readtext('XR.docx')
  regex_XR <- "\\b\\d{1,2} (January|February|March|April|May|June|July|August|September|October|November|December) \\d{4}\\b"
    # dates
    dates_XR <- regmatches(XR$text, gregexpr(regex_XR, XR$text))[[1]]
    dates_XR <- parse_date_time(dates_XR, orders = c("d %B %Y", "d %b %Y"))
    date_table_XR <- table(dates_XR)
    date_df_XR <- data.frame(date = as.Date(names(date_table_XR), format = "%Y-%m-%d"), 
                         frequency = as.numeric(date_table_XR))
    # relative frequency like in google trends
    date_df_XR$relative_frequency <- date_df_XR$frequency / sum(date_df_XR$frequency)


# add 0 as frequency for all dates with no article
  # create a sequence of dates
  dates <- data.frame(date = seq(as.Date("2016-01-01"), as.Date("2020-12-31"), by = "day"))

  # add EG
    # merge tables based on "date" column
    all_dates_EG <- merge(dates, date_df_EG, by = "date", all = TRUE)
    # replace missing values with 0
    all_dates_EG[is.na(all_dates_EG)] <- 0

  # add FfF
    # merge tables based on "date" column
    all_dates_FFF <- merge(dates, date_df_FFF, by = "date", all = TRUE)
    # replace missing values with 0
    all_dates_FFF[is.na(all_dates_FFF)] <- 0

  # add XR
    # merge tables based on "date" column
    all_dates_XR <- merge(dates, date_df_XR, by = "date", all = TRUE)
    # replace missing values with 0
    all_dates_XR[is.na(all_dates_XR)] <- 0

# merge the three data frames based on the common column "date"
all_dates_merged <- merge(merge(all_dates_EG, all_dates_FFF, by = "date"), all_dates_XR, by = "date")

# create weekly aggregates
weekly_data <- all_dates_merged %>%
  group_by(week = format(date, "%Y-%U")) %>%
  summarize(frequency.EG = mean(frequency.x),
            frequency.FFF = mean(frequency.y),
            frequency.XR = mean(frequency),
            frequency.EG.rel = mean(relative_frequency.x),
            frequency.FFF.rel = mean(relative_frequency.y),
            frequency.XR.rel = mean(relative_frequency))

weekly_data$week <- as.Date(paste0(weekly_data$week, "-1"), format = "%Y-%U-%u")

# create relative values

  # for EG
  max_frequency_EG <- max(weekly_data$frequency.EG)
  weekly_data <- weekly_data %>%
    mutate(relative_frequency_EG = frequency.EG / max_frequency_EG * 100)

  # for FfF
  max_frequency_FFF <- max(weekly_data$frequency.FFF)
  weekly_data <- weekly_data %>%
    mutate(relative_frequency_FFF = frequency.FFF / max_frequency_FFF * 100)

  # for XR
  max_frequency_XR <- max(weekly_data$frequency.XR)
  weekly_data <- weekly_data %>%
    mutate(relative_frequency_XR = frequency.XR / max_frequency_XR * 100)

# compile three separate figures

# compile figure EG
EG_plot <- ggplot(weekly_data, aes(x=week)) +
  # general design
  theme(axis.title.x = element_text(family="serif", size = 12, margin = margin(t=10)),
        axis.line.x = element_line(color ='black'),
        axis.title.y = element_text(family="serif", size = 12, margin = margin(r=15)),
        axis.line.y = element_line(color ='black'),
        axis.title.y.right = element_text(angle=90, vjust=0.5),
        panel.background = element_rect(fill='white'),
        plot.margin = unit(c(0,2,1,1), "pt"), legend.position = "none") +
  # axes
  labs(y=element_blank(), x=element_blank()) +
  # add EG time series
  geom_line(aes(y=relative_frequency_EG, color = "EG"), show.legend = TRUE) +
  scale_x_continuous(breaks = seq(as.Date("2016-01-01"), as.Date("2021-01-01"), by = "year"),
                     labels = seq(2016, 2021)) + 
  # define values, protests design
  scale_color_manual(values = c("EG"="darkblue", "FfF"="green", "XR"="steelblue1"), labels = c("Ende Gelände", "Fridays for Future", "Extinction Rebellion"))

  # add the EG protest dates as vertical lines
  EG_plot_2 <- EG_plot + 
    geom_vline(xintercept = as.numeric(as.Date("2016-05-09")), linetype = "dashed", color = "black") + # dates dated to beginning of week
    geom_vline(xintercept = as.numeric(as.Date("2017-08-24")), linetype = "dashed", color = "black") +
    geom_vline(xintercept = as.numeric(as.Date("2017-10-30")), linetype = "dashed", color = "black") +
    geom_vline(xintercept = as.numeric(as.Date("2018-10-01")), linetype = "dashed", color = "black") +
    geom_vline(xintercept = as.numeric(as.Date("2018-10-22")), linetype = "dashed", color = "black") +
    geom_vline(xintercept = as.numeric(as.Date("2019-06-17")), linetype = "dashed", color = "black") +
    geom_vline(xintercept = as.numeric(as.Date("2019-11-25")), linetype = "dashed", color = "black") + # double event
    geom_vline(xintercept = as.numeric(as.Date("2020-01-27")), linetype = "dashed", color = "black") +
    geom_vline(xintercept = as.numeric(as.Date("2020-08-24")), linetype = "dashed", color = "black") +
    geom_vline(xintercept = as.numeric(as.Date("2020-09-21")), linetype = "dashed", color = "black") + # double event
    geom_vline(xintercept = as.numeric(as.Date("2020-11-16")), linetype = "dashed", color = "black") 

# compile figure XR
XR_plot <- ggplot(weekly_data, aes(x=week)) +
  # general design
  theme(axis.title.x = element_text(family="serif", size = 12, margin = margin(t=10)),
        axis.line.x = element_line(color ='black'),
        axis.title.y = element_text(family="serif", size = 12, margin = margin(r=15)),
        axis.line.y = element_line(color ='black'),
        axis.title.y.right = element_text(angle=90, vjust=0.5),
        panel.background = element_rect(fill='white'),
        plot.margin = unit(c(0,2,1,1), "pt"), legend.position = "none") +
  # axes
  labs(y=element_blank(), x=element_blank()) +
  # add XR time series
  geom_line(aes(y=relative_frequency_XR, color = "XR"), show.legend = TRUE) +
  scale_x_continuous(breaks = seq(as.Date("2016-01-01"), as.Date("2021-01-01"), by = "year"),
                     labels = seq(2016, 2021)) + 
  # define values, protests design
  scale_color_manual(values = c("EG"="darkblue", "FfF"="green", "XR"="steelblue1"), labels = c("Ende Gelände", "Fridays for Future", "Extinction Rebellion"))

  # add the XR protest dates as vertical lines
  XR_plot_2 <- XR_plot + 
    geom_vline(xintercept = as.numeric(as.Date("2019-10-07")), linetype = "dashed", color = "black") + 
    geom_vline(xintercept = as.numeric(as.Date("2020-06-29")), linetype = "dashed", color = "black")

# compile figure FFF
FFF_plot <- ggplot(weekly_data, aes(x=week)) +
  # general design
  theme(axis.title.x = element_text(family="serif", size = 12, margin = margin(t=10)),
        axis.line.x = element_line(color ='black'),
        axis.title.y = element_text(family="serif", size = 12, margin = margin(r=15)),
        axis.line.y = element_line(color ='black'),
        axis.title.y.right = element_text(angle=90, vjust=0.5),
        panel.background = element_rect(fill='white'),
        plot.margin = unit(c(0,2,1,1), "pt"), legend.position = "none") +
  # axes
  labs(y=element_blank(), x=element_blank()) +
  # add FfF time series
  geom_line(aes(y=relative_frequency_FFF, color = "FfF"), show.legend = TRUE) +
  scale_x_continuous(breaks = seq(as.Date("2016-01-01"), as.Date("2021-01-01"), by = "year"),
                     labels = seq(2016, 2021)) + 
  # define values, protests design
  scale_color_manual(values = c("EG"="darkblue", "FfF"="green", "XR"="steelblue1"), labels = c("Ende Gelände", "Fridays for Future", "Extinction Rebellion"))

  # add the FFF protest dates as vertical lines
  FFF_plot_2 <- FFF_plot + 
   geom_vline(xintercept = as.numeric(as.Date("2019-03-11")), linetype = "dashed", color = "black") + 
   geom_vline(xintercept = as.numeric(as.Date("2019-05-20")), linetype = "dashed", color = "black") + 
   geom_vline(xintercept = as.numeric(as.Date("2019-09-16")), linetype = "dashed", color = "black") + 
   geom_vline(xintercept = as.numeric(as.Date("2019-11-18")), linetype = "dashed", color = "black") + #double event
   geom_vline(xintercept = as.numeric(as.Date("2020-04-20")), linetype = "dashed", color = "black") + 
   geom_vline(xintercept = as.numeric(as.Date("2020-09-21")), linetype = "dashed", color = "black")  #double event


# combine the plots and create legend at the bottom
combined_plot <- gridExtra::grid.arrange(EG_plot_2, FFF_plot_2, XR_plot_2, ncol = 1, heights = c(3, 3, 3), bottom = legend)

# save final figure
ggsave(plot = combined_plot, width = 13, height = 8, device = png, dpi = 1200, filename = "Sup_Figure 1 - Newspaper Articles.png", path = "C:\\ INSERT YOUR PATH HERE ")
