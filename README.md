# scrapping

Extracting Football Statistics with R

This project utilizes the worldfootballR library to extract, filter, and organize football team statistics from the FBref platform. The script allows users to collect statistics for a given league and export them as an Excel file.

Key Features
- Extraction of team statistics across multiple categories: shooting, passing, keeper, passing_types, gca, defense, misc.
- Combining statistics from all teams into a single Excel file.
- Exporting the data into an Excel file named Database_PL.xlsx.

Prerequisites
Before starting, ensure the following libraries are installed on your system:
- worldfootballR
- dplyr
- writexl

Output:
An Excel file named Database_PL.xlsx will be generated, containing all combined team statistics from the Premier League.

Note:
The full execution of the script may take approximately 22 minutes due to pauses added to respect the FBref server limits.
