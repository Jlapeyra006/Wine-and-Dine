#!/usr/bin/env Rscript

# Wine and Dine v1.0 - Startup Script
# This script checks dependencies and launches the application

cat("🍷 Wine and Dine v1.0 - Starting Application...\n\n")

# Check if required packages are installed
required_packages <- c("shiny", "shinydashboard", "DT", "dplyr", 
                      "readr", "stringr", "ggplot2", "plotly")

cat("Checking required packages...\n")
missing_packages <- c()

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    missing_packages <- c(missing_packages, pkg)
  }
}

# Install missing packages
if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, dependencies = TRUE, 
                  repos = "https://cran.r-project.org")
  
  # Load newly installed packages
  for (pkg in missing_packages) {
    library(pkg, character.only = TRUE)
  }
}

cat("✅ All packages ready!\n\n")

# Check data files
cat("Checking data files...\n")
data_files <- c("data/wine_food_pairings.csv",
               "data/archive (3)/Red.csv",
               "data/archive (3)/White.csv", 
               "data/archive (3)/Rose.csv",
               "data/archive (3)/Sparkling.csv")

missing_files <- c()
for (file in data_files) {
  if (!file.exists(file)) {
    missing_files <- c(missing_files, file)
  }
}

if (length(missing_files) > 0) {
  cat("❌ Missing data files:\n")
  cat(paste("  -", missing_files, collapse = "\n"))
  cat("\n\nPlease ensure all data files are in the correct locations.\n")
  stop("Data files missing. Cannot start application.")
} else {
  cat("✅ All data files found!\n\n")
}

# Launch application
cat("🚀 Launching Wine and Dine application...\n")
cat("📱 Opening in your default web browser...\n")
cat("🌐 Application will be available at: http://localhost:8080\n\n")
cat("Press Ctrl+C to stop the application.\n\n")

# Run the app
shiny::runApp("app.R", port = 8080, host = "0.0.0.0", launch.browser = TRUE)