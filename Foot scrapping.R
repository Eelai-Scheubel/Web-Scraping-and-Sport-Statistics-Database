# Importation des librairies
library(worldfootballR)
library(dplyr)
library(writexl)

# Fonction pour extraire et filtrer les différentes catégories de statistiques (shooting, passing, etc...)
filter_stat <- function(team_urls, stat_type, comp) {           # team_urls = lien de l'équipe, stat_type = catégorie de stat, comp = compétition
  stats <- fb_team_match_log_stats(team_urls = team_urls, stat_type = stat_type) %>%
    filter(Comp == comp, ForAgainst == "For") %>%
  
    # Suppression des colonnes inutiles
    select(-all_of(if (stat_type == "shooting") {
      c("Team_Url", "ForAgainst", "Gls_Standard")
    } else {
      c(1:13)
    }))
  return(stats)
}

# Fonction pour fusionner les statistiques d'une équipe
combine_team_stats <- function(team_url, stat_types, comp) {
  stats_list <- lapply(stat_types, function(stat_type) {
    filter_stat(team_url, stat_type, comp)
  })
  merged_df <- do.call(cbind, stats_list) # On fusionne les différentes catégories de statistiques d'une équipe en un seul dataframe
  return(merged_df)
}

# Fonction principale
fetch_premier_league_stats <- function(url, stat_types, comp) {
  team_urls <- fb_teams_urls(url)
  
  # On fusionne les différentes catégories de statistiques pour toutes les équipes du championnat
  final_data_frames <- lapply(team_urls, function(team_url) {
    combine_team_stats(team_url, stat_types, comp) 
  })
  combined_df <- bind_rows(final_data_frames) # Fusion des stats de toutes les équipes
  return(combined_df)
}

### Utilisation pour n'importe quelle championnat (ici la saison 2023-2024 de la Premier League)
url <- "https://fbref.com/en/comps/9/2023-2024/2023-2024-Premier-League-Stats"  # Lien du championnat 
stat_types <- c("shooting", "passing", "keeper", "passing_types", "gca", "defense", "misc") # Les catégories de statistiques qui nous intéressent
comp <- "Premier League" # Nom de la compétition
name_xl <- "Database_PL.xlsx"

# Récupération des statistiques
combined_df <- fetch_premier_league_stats(url, stat_types, comp)

# Sauvegarde du résultat sous fichier excel
write_xlsx(combined_df, name_xl)
