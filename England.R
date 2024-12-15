library(worldfootballR)
library(dplyr)
library(magrittr)
library(writexl)

response <- httr::GET("https://fbref.com/en/comps/9/2023-2024/2023-2024-Premier-League-Stats")
retry_after <- httr::headers(response)$`retry-after`
print(retry_after)
if (!is.null(retry_after))
  Sys.sleep(as.numeric(retry_after))  # Wait according to the server's recommendation



url <- fb_teams_urls("https://fbref.com/en/comps/9/2023-2024/2023-2024-Premier-League-Stats")
#url_italy 
#url_spain <- 
#url_germany <- 

final_data_frames <- list()

for (i in 1:length(url)) {
  shooting <- dplyr::filter(fb_team_match_log_stats(team_urls = url[i], stat_type = "shooting"), Comp == "Premier League", ForAgainst == "For")
  shooting <- subset(shooting, select = -c(Team_Url, ForAgainst, Date, Time, Comp, Day, Venue, Result, GA, Gls_Standard))
  Sys.sleep(3)
  
  passing <- dplyr::filter(fb_team_match_log_stats(team_urls = url[i], stat_type = "passing"), Comp == "Premier League", ForAgainst == "For")
  passing <- subset(passing, select = -c(1:13))
  Sys.sleep(3)
  
  keeper <- dplyr::filter(fb_team_match_log_stats(team_urls = url[i], stat_type = "keeper"), Comp == "Premier League", ForAgainst == "For")
  keeper <- subset(keeper, select = -c(1:13))
  Sys.sleep(3)
  
  passing_types <- dplyr::filter(fb_team_match_log_stats(team_urls = url[i], stat_type = "passing_types"), Comp == "Premier League", ForAgainst == "For")
  passing_types <- subset(passing_types, select = -c(1:13))
  Sys.sleep(3)
  
  gca <-dplyr::filter(fb_team_match_log_stats(team_urls = url[i], stat_type = "gca"), Comp == "Premier League", ForAgainst == "For")
  gca <- subset(gca, select = -c(1:13))
  Sys.sleep(3)
  
  defense <- dplyr::filter(fb_team_match_log_stats(team_urls = url[i], stat_type = "defense"), Comp == "Premier League", ForAgainst == "For")
  defense <- subset(defense, select = -c(1:13))
  Sys.sleep(3)
  
  misc <- dplyr::filter(fb_team_match_log_stats(team_urls = url[i], stat_type = "misc"), Comp == "Premier League", ForAgainst == "For")
  misc <- subset(misc, select = -c(1:13))
  Sys.sleep(3)
  
  merged_df <- cbind(shooting, passing, keeper, passing_types, gca, defense, misc)

  final_data_frames[[i]] <- merged_df
}

combined_df <- bind_rows(final_data_frames)

combined_df <- combined_df %>%
  mutate(Round = as.numeric(gsub("Matchweek ", "", Round)))

averaged_df <- combined_df %>%
  arrange(Team, Round) %>% # Ensure the dataframe is sorted by Team and Round
  group_by(Team) %>%
  mutate(across(
    .cols = 4:(ncol(combined_df)-1), # Adjust range to exclude the first 4 columns
    .fns = ~ ifelse(Round == 1, NA, lag(cummean(.))), # Use lag to exclude current Round
    .names = NULL # Keep the original column names
  )) %>%
  ungroup()

final_df_england <- averaged_df %>%
  filter(Round >= 10 & Round <= 38)

final_df_england <- final_df_england %>%
  select(-"G_per_SoT_Standard", -"Save_percent_Performance", -"Cmp_percent_Launched", -"Launch_percent_Goal_Kicks", -"AvgLen_Goal_Kicks", -"AvgDist_Sweeper")

write_xlsx(final_df_england, "Database PL.xlsx")
