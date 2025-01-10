library(worldfootballR)
library(dplyr)
library(magrittr)
library(writexl)

# Fonction pour extraire et traiter un type de statistique
process_stat <- function(team_urls, stat_type, filter_cols) {
  stats <- fb_team_match_log_stats(team_urls = team_urls, stat_type = stat_type) %>%
    filter(Comp == "Premier League", ForAgainst == "For") %>%
    select(-all_of(filter_cols)) # Suppression des colonnes inutiles
  Sys.sleep(3) # Pause entre les requêtes pour éviter une surcharge du serveur
  return(stats)
}

# URL des équipes
url <- fb_teams_urls("https://fbref.com/en/comps/9/2023-2024/2023-2024-Premier-League-Stats")

# Spécifications des types de statistiques et des colonnes à supprimer
stat_types <- c("shooting", "passing", "keeper", "passing_types", "gca", "defense", "misc")
cols_to_remove <- list(
  shooting = c("Team_Url", "ForAgainst", "Date", "Time", "Comp", "Day", "Venue", "Result", "GA", "Gls_Standard"), # Colonnes spécifiques pour "shooting"
  other_stats = c(1:13) # Colonnes communes à supprimer pour les autres statistiques
)

final_data_frames <- list()

# Boucle sur chaque équipe
for (i in seq_along(url)) {
  team_url <- url[i]
  
  # Traitement de tous les types de statistiques
  stats_list <- lapply(stat_types, function(stat_type) {
    filter_cols <- if (stat_type == "shooting") cols_to_remove$shooting else cols_to_remove$other_stats
    process_stat(team_url, stat_type, filter_cols)
  })
  
  # Combinaison des statistiques pour l'équipe actuelle
  merged_df <- do.call(cbind, stats_list)
  final_data_frames[[i]] <- merged_df
}

# Fusion de toutes les équipes en un seul dataframe
combined_df <- bind_rows(final_data_frames)
# Sauvegarde du résultat
write_xlsx(combined_df, "Database PL.xlsx")
