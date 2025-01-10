library(worldfootballR)
library(dplyr)
library(magrittr)
library(writexl)

# Funcție pentru extragerea și procesarea unui tip de statistică
process_stat <- function(team_urls, stat_type, filter_cols) {
  stats <- fb_team_match_log_stats(team_urls = team_urls, stat_type = stat_type) %>%
    filter(Comp == "Premier League", ForAgainst == "For") %>%
    select(-all_of(filter_cols))
  Sys.sleep(3) # Pauză între cereri
  return(stats)
}

# URL-ul echipelor
url <- fb_teams_urls("https://fbref.com/en/comps/9/2023-2024/2023-2024-Premier-League-Stats")

# Specificații pentru tipurile de statistici și coloane de eliminat
stat_types <- c("shooting", "passing", "keeper", "passing_types", "gca", "defense", "misc")
cols_to_remove <- list(
  shooting = c("Team_Url", "ForAgainst", "Date", "Time", "Comp", "Day", "Venue", "Result", "GA", "Gls_Standard"),
  other_stats = c(1:13) # Coloane comune de eliminat
)

final_data_frames <- list()

# Iterăm pentru fiecare echipă
for (i in seq_along(url)) {
  team_url <- url[i]
  
  # Procesăm toate tipurile de statistici
  stats_list <- lapply(stat_types, function(stat_type) {
    filter_cols <- if (stat_type == "shooting") cols_to_remove$shooting else cols_to_remove$other_stats
    process_stat(team_url, stat_type, filter_cols)
  })
  
  # Combinăm statisticile pentru echipa curentă
  merged_df <- do.call(cbind, stats_list)
  final_data_frames[[i]] <- merged_df
}

# Combinăm toate echipele într-un singur dataframe
combined_df <- bind_rows(final_data_frames)
