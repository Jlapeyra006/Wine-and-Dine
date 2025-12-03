# Shiny UI
# ui.R

source("wine_data_loader.R")

# Define UI
ui <- dashboardPage(
  skin = "red",
  
  # Header
  dashboardHeader(
    title = "🍷 Wine & Food Pairing Assistant",
    titleWidth = 350
  ),
  
  # Sidebar
  dashboardSidebar(
    width = 280,
    sidebarMenu(
      menuItem("🔍 Search Pairings", tabName = "search", icon = icon("search")),
      menuItem("📊 Analytics", tabName = "analytics", icon = icon("chart-bar")),
      menuItem("📖 About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  # Body
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .small-box {
          border-radius: 10px;
        }
        .box {
          border-radius: 10px;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .btn-primary {
          background-color: #722f37;
          border-color: #722f37;
        }
        .btn-primary:hover {
          background-color: #5a252a;
          border-color: #5a252a;
        }
        .nav-tabs-custom > .nav-tabs > li.active {
          border-top-color: #722f37;
        }
        /* Enhanced DataTable styling for wine details */
        .dataTables_wrapper {
          font-size: 13px;
        }
        .dataTables_wrapper table.dataTable thead th {
          background-color: #722f37;
          color: white;
          font-weight: bold;
          border-bottom: 2px solid #5a252a;
        }
        .dataTables_wrapper table.dataTable tbody tr:hover {
          background-color: #f8f4f5;
        }
        .dataTables_wrapper table.dataTable tbody td {
          vertical-align: middle;
          padding: 8px;
        }
        .wine-rating {
          color: #f39c12;
          font-weight: bold;
        }
        .wine-price {
          color: #27ae60;
          font-weight: bold;
        }
        .pairing-quality {
          background-color: #e8f5e8;
          padding: 3px 6px;
          border-radius: 3px;
          font-weight: bold;
        }
      "))
    ),
    
    tabItems(
      # Search Tab
      tabItem(
        tabName = "search",
        
        # Value boxes
        fluidRow(
          valueBoxOutput("total_pairings"),
          valueBoxOutput("total_wines"), 
          valueBoxOutput("avg_rating")
        ),
        
        # Search Interface
        fluidRow(
          box(
            title = "🔍 Search Options", status = "primary", solidHeader = TRUE,
            width = 4, height = "auto",
            
            # Search type selection
            radioButtons(
              "search_type",
              "What would you like to find?",
              choices = list(
                "🍷 Find wines for my food" = "food_to_wine",
                "🍽️ Find foods for my wine" = "wine_to_food"
              ),
              selected = "food_to_wine"
            ),
            
            hr(),
            
            # Conditional search inputs
            conditionalPanel(
              condition = "input.search_type == 'food_to_wine'",
              h4("🍽️ Food Search"),
              
              # Category first - REQUIRED
              selectInput(
                "food_category_filter",
                "Food Category (Required):",
                choices = c("Select Category..." = ""),
                selected = ""
              ),
              
              # Food selection based on category
              conditionalPanel(
                condition = "input.food_category_filter != ''",
                selectInput(
                  "food_item_select",
                  "Select Food Item:",
                  choices = c("Choose food..." = ""),
                  selected = ""
                )
              ),
              
              # Optional cuisine filter
              selectInput(
                "cuisine_filter_food",
                "Cuisine (Optional):",
                choices = c("All Cuisines" = ""),
                selected = ""
              )
            ),
            
            conditionalPanel(
              condition = "input.search_type == 'wine_to_food'",
              h4("🍷 Wine Search"),
              
              # Wine category first - REQUIRED
              selectInput(
                "wine_category_filter",
                "Wine Category (Required):",
                choices = c("Select Category..." = ""),
                selected = ""
              ),
              
              # Wine selection based on category  
              conditionalPanel(
                condition = "input.wine_category_filter != ''",
                selectInput(
                  "wine_type_select",
                  "Select Wine Type:",
                  choices = c("Choose wine..." = ""),
                  selected = ""
                )
              ),
              
              # Specific wine bottle selection
              conditionalPanel(
                condition = "input.wine_type_select != ''",
                selectInput(
                  "specific_wine_select",
                  "Select Specific Wine (Optional - or search all wines of this type):",
                  choices = c("All wines of this type" = "", "Loading..."),
                  selected = ""
                )
              ),
              
              # Optional cuisine filter for food results
              selectInput(
                "cuisine_filter_wine", 
                "Cuisine Filter for Food Results (Optional):",
                choices = c("All Cuisines" = ""),
                selected = ""
              )
            ),
            
            # Additional filters
            hr(),
            h5("🎛️ Wine Filters"),
            
            sliderInput(
              "price_range",
              "Price Range ($):",
              min = 0, max = 500, value = c(0, 100),
              step = 5
            ),
            sliderInput(
              "rating_filter",
              "Minimum Wine Rating:",
              min = 1, max = 5, value = 3,
              step = 0.1
            ),
            
            h5("🎯 Pairing Quality"),
            sliderInput(
              "pairing_quality_filter",
              "Minimum Pairing Quality:",
              min = 1, max = 5, value = 3,
              step = 0.1
            ),
            
            selectInput(
              "cuisine_filter",
              "Cuisine (optional):",
              choices = c("All Cuisines" = ""),
              selected = ""
            ),
            
            # Search button - properly spaced at bottom
            br(),
            br(),
            div(
              style = "margin-top: 20px; text-align: center;",
              actionButton(
                "search_btn", 
                "🔍 Search", 
                class = "btn-primary btn-lg",
                style = "font-weight: bold; height: 50px; width: 90%; font-size: 16px;"
              )
            )
          ),
          
          # Results panel with enhanced display
          box(
            title = "🍷 Specific Wine Bottles & Details", status = "primary", solidHeader = TRUE,
            width = 8, height = "auto",
            
            conditionalPanel(
              condition = "input.search_type == 'food_to_wine'",
              h4("🍷 Individual Wine Bottles with Complete Details"),
              p(style = "color: #666; font-size: 14px;", 
                "Showing specific wine bottles including producer, vintage, exact location, price, and professional ratings for each wine type."),
              withSpinner(DT::dataTableOutput("wine_results"))
            ),
            
            conditionalPanel(
              condition = "input.search_type == 'wine_to_food'",
              h4("🍽️ Recommended Food Pairings"),
              withSpinner(DT::dataTableOutput("food_results"))
            )
          )
        ),
        
        # Add some spacing before detailed results
        br(),
        
        # Detailed results - moved further down
        fluidRow(
          box(
            title = "📊 Detailed Analysis", status = "info", solidHeader = TRUE,
            width = 12,
            
            tabsetPanel(
              tabPanel(
                "📈 Price vs Rating",
                withSpinner(plotlyOutput("price_rating_plot"))
              ),
              tabPanel(
                "🌍 Geographic Distribution", 
                withSpinner(plotlyOutput("geographic_plot"))
              ),
              tabPanel(
                "⭐ Quality Analysis",
                withSpinner(plotlyOutput("quality_plot"))
              )
            )
          )
        )
      ),
      
      # Analytics Tab
      tabItem(
        tabName = "analytics",
        
        fluidRow(
          box(
            title = "📊 Database Overview", status = "primary", solidHeader = TRUE,
            width = 6,
            withSpinner(plotlyOutput("pairing_overview"))
          ),
          
          box(
            title = "🍷 Wine Distribution", status = "primary", solidHeader = TRUE,
            width = 6,
            withSpinner(plotlyOutput("wine_distribution"))
          )
        ),
        
        fluidRow(
          box(
            title = "💰 Price Analysis", status = "info", solidHeader = TRUE,
            width = 6,
            withSpinner(plotlyOutput("price_analysis"))
          ),
          
          box(
            title = "⭐ Rating Trends", status = "info", solidHeader = TRUE,
            width = 6,
            withSpinner(plotlyOutput("rating_trends"))
          )
        ),
        
        fluidRow(
          box(
            title = "🌍 Top Wine Regions", status = "success", solidHeader = TRUE,
            width = 12,
            withSpinner(DT::dataTableOutput("region_analysis"))
          )
        )
      ),
      
      # About Tab
      tabItem(
        tabName = "about",
        
        fluidRow(
          box(
            title = "🍷 About Wine & Food Pairing Assistant", status = "primary", solidHeader = TRUE,
            width = 12,
            
            h3("Welcome to the Wine & Food Pairing Assistant!"),
            p("This application helps you discover perfect wine and food combinations based on our comprehensive database of pairing recommendations."),
            
            h4("🔍 How to Use:"),
            tags$ul(
              tags$li("Choose whether you want to find wines for your food or foods for your wine"),
              tags$li("Enter your search term or select from our curated lists"), 
              tags$li("Apply filters for price, rating, cuisine, and more"),
              tags$li("Explore detailed results with sorting and visualization options")
            ),
            
            h4("📊 Database Information:"),
            tags$div(
              style = "background: #f8f9fa; padding: 15px; border-radius: 5px; margin: 10px 0;",
              tags$p(strong("Data Sources:")),
              tags$ul(
                tags$li("Wine-Food Pairing Database: 34,000+ pairing combinations"),
                tags$li("Wine Catalogs: 14,000+ wines across all categories"),
                tags$li("Professional Reviews: 150,000+ expert wine reviews"),
                tags$li("Quality Analysis: Chemical composition data"),
                tags$li("Wine Varieties: 1,500+ grape varieties")
              )
            ),
            
            h4("🎯 Features:"),
            tags$ul(
              tags$li("Bi-directional search (food→wine or wine→food)"),
              tags$li("Advanced filtering by price, rating, region, and cuisine"),
              tags$li("Interactive visualizations and analytics"),
              tags$li("Detailed wine information including ratings and prices"),
              tags$li("Pairing quality scores and expert descriptions")
            ),
            
            br(),
            div(
              style = "text-align: center; padding: 20px; background: #722f37; color: white; border-radius: 10px;",
              h4("🍷 Cheers to Perfect Pairings! 🍽️"),
              p("Discover your next favorite wine and food combination with confidence.")
            )
          )
        )
      )
    )
  )
)