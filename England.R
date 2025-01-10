# Installer les librairies
library(worldfootballR)
library(dplyr)
library(writexl)

# Système de délai pour pas être bloquer par le site
response <- httr::GET("https://fbref.com/en/comps/9/2023-2024/2023-2024-Premier-League-Stats")
retry_after <- httr::headers(response)$`retry-after`
print(retry_after)
if (!is.null(retry_after))
  Sys.sleep(as.numeric(retry_after))  # Wait according to the server's recommendation


# Url du championnat
url_england <- fb_teams_urls("https://fbref.com/en/comps/9/2023-2024/2023-2024-Premier-League-Stats")


# Scrapping pour toutes les équipes du championnat
for (i in 1:length(url_england)) {
  shooting <- dplyr::filter(fb_team_match_log_stats(team_urls = url_england[i], stat_type = "shooting"), Comp == "Premier League", ForAgainst == "For")
  shooting <- subset(shooting, select = -c(Team_Url, ForAgainst, Date, Time, Comp, Day, Venue, Result, GA, Gls_Standard))
  Sys.sleep(3)
  
  passing <- dplyr::filter(fb_team_match_log_stats(team_urls = url_england[i], stat_type = "passing"), Comp == "Premier League", ForAgainst == "For")
  passing <- subset(passing, select = -c(1:13))
  Sys.sleep(3)
  
  keeper <- dplyr::filter(fb_team_match_log_stats(team_urls = url_england[i], stat_type = "keeper"), Comp == "Premier League", ForAgainst == "For")
  keeper <- subset(keeper, select = -c(1:13))
  Sys.sleep(3)
  
  passing_types <- dplyr::filter(fb_team_match_log_stats(team_urls = url_england[i], stat_type = "passing_types"), Comp == "Premier League", ForAgainst == "For")
  passing_types <- subset(passing_types, select = -c(1:13))
  Sys.sleep(3)
  
  gca <-dplyr::filter(fb_team_match_log_stats(team_urls = url_england[i], stat_type = "gca"), Comp == "Premier League", ForAgainst == "For")
  gca <- subset(gca, select = -c(1:13))
  Sys.sleep(3)
  
  defense <- dplyr::filter(fb_team_match_log_stats(team_urls = url_england[i], stat_type = "defense"), Comp == "Premier League", ForAgainst == "For")
  defense <- subset(defense, select = -c(1:13))
  Sys.sleep(3)
  
  misc <- dplyr::filter(fb_team_match_log_stats(team_urls = url_england[i], stat_type = "misc"), Comp == "Premier League", ForAgainst == "For")
  misc <- subset(misc, select = -c(1:13))
  Sys.sleep(3)
  
  merged_df <- cbind(shooting, passing, keeper, passing_types, gca, defense, misc)
  
  final_data_frames[[i]] <- merged_df
}

# Combiner les stats de toutes les équipes en une database
combined_df <- bind_rows(final_data_frames)

# Transformer en un fichier excel
write_xlsx(final_df_england, "Database PL.xlsx")
