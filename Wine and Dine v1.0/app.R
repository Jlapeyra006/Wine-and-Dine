# Main Shiny App File
# app.R

# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(dplyr)
library(readr)
library(plotly)
library(ggplot2)
library(shinycssloaders)
library(shinyWidgets)
library(stringr)

# Source UI and Server files
source("ui.R")
source("server.R")

# Run the application
shinyApp(ui = ui, server = server)