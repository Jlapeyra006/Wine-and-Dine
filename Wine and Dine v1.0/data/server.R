# Shiny Server
# server.R

source("wine_data_loader.R")

server <- function(input, output, session) {
  
  # Load data on startup
  wine_data <- reactive({
    data <- load_wine_data()
    if (is.null(data)) {
      return(NULL)
    }
    
    return(data)
  })
  
  # Get unique values for dropdown choices
  observe({
    req(wine_data())
    
    tryCatch({
      data <- wine_data()
      
      # Safely get unique values
      food_categories <- sort(unique(data$pairings$food_category[!is.na(data$pairings$food_category)]))
      wine_categories <- sort(unique(data$pairings$wine_category[!is.na(data$pairings$wine_category)]))
      cuisines <- sort(unique(data$pairings$cuisine[!is.na(data$pairings$cuisine)]))
      
      # Update category dropdowns
      updateSelectInput(
        session, "food_category_filter", 
        choices = c("Select Category..." = "", food_categories)
      )
      
      updateSelectInput(
        session, "wine_category_filter",
        choices = c("Select Category..." = "", wine_categories)
      )
      
      # Update cuisine filters
      updateSelectInput(
        session, "cuisine_filter",
        choices = c("All Cuisines" = "", cuisines)
      )
      
      updateSelectInput(
        session, "cuisine_filter_food",
        choices = c("All Cuisines" = "", cuisines)
      )
      
      updateSelectInput(
        session, "cuisine_filter_wine",
        choices = c("All Cuisines" = "", cuisines)
      )
      
    }, error = function(e) {
      # Provide basic fallback choices
      updateSelectInput(
        session, "food_category_filter", 
        choices = c("Select Category..." = "", "Red Meat", "Seafood", "Poultry", "Pasta", "Cheese")
      )
      
      updateSelectInput(
        session, "wine_category_filter",
        choices = c("Select Category..." = "", "Red", "White", "Rose", "Sparkling")
      )
    })
  })
  
  # Update food items based on selected food category
  observe({
    req(wine_data(), input$food_category_filter)
    
    if (input$food_category_filter != "") {
      data <- wine_data()
      food_items <- sort(unique(data$pairings$food_item[
        data$pairings$food_category == input$food_category_filter & 
        !is.na(data$pairings$food_item)
      ]))
      
      updateSelectInput(
        session, "food_item_select",
        choices = c("Choose food..." = "", food_items)
      )
    }
  })
  
  # Update wine types based on selected wine category
  observe({
    req(wine_data(), input$wine_category_filter)
    
    if (input$wine_category_filter != "") {
      data <- wine_data()
      wine_types <- sort(unique(data$pairings$wine_type[
        data$pairings$wine_category == input$wine_category_filter & 
        !is.na(data$pairings$wine_type)
      ]))
      
      updateSelectInput(
        session, "wine_type_select",
        choices = c("Choose wine..." = "", wine_types)
      )
    }
  })
  
  # Update specific wines based on selected wine type
  observe({
    req(wine_data(), input$wine_type_select)
    
    if (input$wine_type_select != "") {
      data <- wine_data()
      
      # Map wine type to wine category for catalog lookup
      wine_category_mapped <- case_when(
        grepl("Cabernet|Merlot|Pinot Noir|Syrah|Shiraz|Malbec|Sangiovese|Nebbiolo|Grenache|Tempranillo|Zinfandel|Barbera|Petite Sirah", input$wine_type_select, ignore.case = TRUE) ~ "Red",
        grepl("Chardonnay|Sauvignon Blanc|Pinot Grigio|Pinot Gris|Riesling|Gewürztraminer|Viognier|Albariño|Chenin Blanc|Grüner Veltliner|Moscato|Vermentino", input$wine_type_select, ignore.case = TRUE) ~ "White", 
        grepl("Rosé|Rose", input$wine_type_select, ignore.case = TRUE) ~ "Rose",
        grepl("Champagne|Cava|Prosecco|Crémant|Sparkling", input$wine_type_select, ignore.case = TRUE) ~ "Sparkling",
        TRUE ~ "Red"
      )
      
      # Get specific wines for this category - diverse selection across price ranges
      specific_wines <- data$all_wines %>%
        filter(wine_category == wine_category_mapped) %>%
        arrange(price_range, name, desc(rating)) %>%  # Sort by price range first for diversity
        group_by(price_range) %>%
        slice_head(n = 8) %>%  # Take 8 wines per price range
        ungroup() %>%
        arrange(name) %>%  # Final alphabetical sort
        mutate(display_name = paste0(name, 
                                   ifelse(is.na(year) | year == "N.V.", "", paste0(" (", year, ")")),
                                   " - ", winery,
                                   ifelse(!is.na(price), paste0(" - $", round(price, 2)), ""))) %>%
        slice_head(n = 30)  # Increased limit to show more variety
      
      wine_choices <- setNames(specific_wines$name, specific_wines$display_name)
      
      updateSelectInput(
        session, "specific_wine_select",
        choices = c("All wines of this type" = "", wine_choices)
      )
    }
  })
  
  # Update price range based on available data
  observe({
    req(wine_data())
    price_range <- range(wine_data()$all_wines$price, na.rm = TRUE)
    updateSliderInput(
      session, "price_range",
      min = floor(price_range[1]), 
      max = ceiling(price_range[2]),
      value = c(floor(price_range[1]), min(100, ceiling(price_range[2])))
    )
  })
  
  # Value boxes - simplified to avoid showNotification errors
  output$total_pairings <- renderValueBox({
    req(wine_data())
    count <- nrow(wine_data()$pairings)
    valueBox(
      value = format(count, big.mark = ","),
      subtitle = "Wine-Food Pairings",
      icon = icon("wine-glass")
    )
  })
  
  output$total_wines <- renderValueBox({
    req(wine_data())
    count <- nrow(wine_data()$all_wines)
    valueBox(
      value = format(count, big.mark = ","),
      subtitle = "Wines in Database", 
      icon = icon("warehouse")
    )
  })
  
  output$avg_rating <- renderValueBox({
    req(wine_data())
    avg_rating <- round(mean(wine_data()$all_wines$rating, na.rm = TRUE), 1)
    valueBox(
      value = paste(avg_rating, "⭐"),
      subtitle = "Average Wine Rating",
      icon = icon("star")
    )
  })
  
  # Search results for food to wine
  wine_search_results <- eventReactive(input$search_btn, {
    req(wine_data())
    
    # Only proceed if this is a food-to-wine search
    if(input$search_type != "food_to_wine") {
      return(data.frame())
    }
    
    if (is.null(input$food_category_filter) || input$food_category_filter == "") {
      return(data.frame(Message = "Please select a food category first"))
    }
    
    if (is.null(input$food_item_select) || input$food_item_select == "") {
      return(data.frame(Message = "Please select a specific food item"))
    }
    
    # Get pairings data
    pairings <- wine_data()$pairings
    wines <- wine_data()$all_wines
    
    # Filter by selected food item
    results <- pairings %>%
      filter(food_item == input$food_item_select)
    
    # Apply cuisine filter if selected
    if (!is.null(input$cuisine_filter_food) && input$cuisine_filter_food != "") {
      results <- results %>% filter(cuisine == input$cuisine_filter_food)
    }
    
    # Apply pairing quality filter
    if (!is.null(input$pairing_quality_filter)) {
      results <- results %>% filter(pairing_quality >= input$pairing_quality_filter)
    }
    
    if (nrow(results) == 0) {
      return(data.frame(Message = "No wine pairings found for the selected criteria"))
    }

    # Simplified approach: Join with wine catalog using a basic mapping
    # Create a simple wine category mapping
    results_with_wine_category <- results %>%
      mutate(
        wine_category_mapped = case_when(
          grepl("Cabernet|Merlot|Pinot Noir|Syrah|Shiraz|Malbec|Sangiovese|Nebbiolo|Grenache|Tempranillo|Zinfandel|Barbera|Petite Sirah", wine_type, ignore.case = TRUE) ~ "Red",
          grepl("Chardonnay|Sauvignon Blanc|Pinot Grigio|Pinot Gris|Riesling|Gewürztraminer|Viognier|Albariño|Chenin Blanc|Grüner Veltliner|Moscato|Vermentino", wine_type, ignore.case = TRUE) ~ "White", 
          grepl("Rosé|Rose", wine_type, ignore.case = TRUE) ~ "Rose",
          grepl("Champagne|Cava|Prosecco|Crémant|Sparkling", wine_type, ignore.case = TRUE) ~ "Sparkling",
          TRUE ~ "Red"  # Default to Red for unknowns
        )
      )
    
    # Get a sample of wines for each category - diverse across price ranges
    wine_samples <- wines %>%
      group_by(wine_category, price_range) %>%
      arrange(desc(rating)) %>%
      slice_head(n = 1) %>%  # Top wine per category per price range
      ungroup() %>%
      group_by(wine_category) %>%
      slice_head(n = 3)  # Top 3 price ranges per category
    
    # Join the results with wine samples and implement proper deduplication
    detailed_results <- results_with_wine_category %>%
      left_join(wine_samples, by = c("wine_category_mapped" = "wine_category"), relationship = "many-to-many") %>%
      filter(!is.na(name)) %>%
      # Group by unique wine identity and keep the best pairing quality
      group_by(name, winery, year) %>%
      arrange(desc(pairing_quality)) %>%
      slice_head(n = 1) %>%  # Keep only the best pairing for each unique wine
      ungroup() %>%
      arrange(desc(pairing_quality), desc(rating)) %>%
      select(
        wine_name = name,
        full_wine_name = full_wine_name,
        winery = winery,
        vintage = year,
        country = country,
        region = region,
        price = price,
        wine_rating = rating,
        wine_category = wine_category,
        pairing_quality,
        quality_label,
        description,
        food_item,
        cuisine,
        price_range,
        rating_category,
        wine_type = wine_type  # Keep the original wine type for display
      )
    
    # Apply price and rating filters BEFORE formatting
    if (!is.null(input$price_range) && any(!is.na(detailed_results$price))) {
      detailed_results <- detailed_results %>%
        filter(is.na(price) | 
               (as.numeric(price) >= input$price_range[1] & as.numeric(price) <= input$price_range[2]))
    }

    if (!is.null(input$rating_filter) && any(!is.na(detailed_results$wine_rating))) {
      detailed_results <- detailed_results %>%
        filter(is.na(wine_rating) | 
               as.numeric(wine_rating) >= input$rating_filter)
    }
    
    # Now format the display values
    detailed_results <- detailed_results %>%
      mutate(
        # Clean up data formatting with USD symbols
        price = ifelse(!is.na(price) & is.numeric(price), paste0("$", round(price, 2)), "N/A"),
        wine_rating = ifelse(!is.na(wine_rating) & is.numeric(wine_rating), round(wine_rating, 1), NA),
        vintage = ifelse(!is.na(vintage), vintage, "N.V."),
        winery = ifelse(!is.na(winery) & winery != "", winery, "Various Producers"),
        region = ifelse(!is.na(region) & region != "", region, "Various Regions"),
        country = ifelse(!is.na(country) & country != "", country, "Various Countries")
      )
    
    return(detailed_results)
  })  # Search results for wine to food
  food_search_results <- eventReactive(input$search_btn, {
    req(wine_data())
    
    # Only proceed if this is a wine-to-food search
    if(input$search_type != "wine_to_food") {
      return(data.frame())
    }
    
    if (is.null(input$wine_category_filter) || input$wine_category_filter == "") {
      return(data.frame(Message = "Please select a wine category first"))
    }
    
    if (is.null(input$wine_type_select) || input$wine_type_select == "") {
      return(data.frame(Message = "Please select a specific wine type"))
    }
    
    pairings <- wine_data()$pairings
    wines <- wine_data()$all_wines
    
    # Filter by selected wine type
    results <- pairings %>%
      filter(wine_type == input$wine_type_select)
    
    # Initialize specific wine columns with default values
    results <- results %>%
      mutate(
        specific_wine_name = NA_character_,
        specific_winery = NA_character_,
        specific_vintage = NA_character_,
        specific_region = NA_character_,
        specific_country = NA_character_,
        specific_price = NA_real_,
        specific_rating = NA_real_
      )
    
    # If a specific wine is selected, add wine details
    if (!is.null(input$specific_wine_select) && input$specific_wine_select != "") {
      specific_wine_info <- wines %>%
        filter(name == input$specific_wine_select) %>%
        slice_head(n = 1)
      
      if (nrow(specific_wine_info) > 0) {
        results <- results %>%
          mutate(
            specific_wine_name = specific_wine_info$name,
            specific_winery = specific_wine_info$winery,
            specific_vintage = specific_wine_info$year,
            specific_region = specific_wine_info$region,
            specific_country = specific_wine_info$country,
            specific_price = specific_wine_info$price,
            specific_rating = specific_wine_info$rating
          )
      }
    }
    
    # Apply cuisine filter if selected  
    if (!is.null(input$cuisine_filter_wine) && input$cuisine_filter_wine != "") {
      results <- results %>% filter(cuisine == input$cuisine_filter_wine)
    }
    
    # Apply pairing quality filter
    if (!is.null(input$pairing_quality_filter)) {
      results <- results %>% filter(pairing_quality >= input$pairing_quality_filter)
    }
    
    if (nrow(results) == 0) {
      return(data.frame(Message = "No food pairings found for the selected criteria"))
    }
    
    # Remove duplicates by keeping the best pairing quality for unique combinations
    # First handle the case where specific wine is selected
    if ("specific_wine_name" %in% names(results)) {
      # For specific wine, deduplicate by food item keeping highest quality
      results <- results %>%
        group_by(food_item, specific_wine_name, specific_winery) %>%
        arrange(desc(pairing_quality)) %>%
        slice_head(n = 1) %>%
        ungroup()
    } else {
      # For wine type search, only remove exact duplicates, allow multiple foods per wine type
      results <- results %>%
        distinct(food_item, wine_type, pairing_quality, .keep_all = TRUE) %>%
        arrange(desc(pairing_quality))
    }
    
    # Format results with detailed food information
    detailed_results <- results %>%
      arrange(desc(pairing_quality)) %>%
      select(
        food_name = food_item,
        food_category,
        cuisine,
        preparation_style = description,
        pairing_quality,
        quality_label,
        wine_type,
        wine_category
      ) %>%
      mutate(
        pairing_score = paste0(round(pairing_quality, 1), "/5.0"),
        food_display = paste0(food_name, " (", food_category, ")"),
        cuisine_style = ifelse(!is.na(cuisine), paste0(cuisine, " cuisine"), "International")
      )
    
    return(detailed_results)
  })
  
  # Render wine results table
  output$wine_results <- DT::renderDataTable({
    results <- wine_search_results()
    
    if (nrow(results) == 0 || "Message" %in% names(results)) {
      if("Message" %in% names(results)) {
        return(results)
      } else {
        return(data.frame("Status" = "Click Search to find wine recommendations"))
      }
    }
    
    # Format the data for display with specific wine bottle details
    display_data <- results %>%
      mutate(
        # Use the full wine name if available, otherwise construct it
        `Wine & Vintage` = ifelse(!is.na(full_wine_name), full_wine_name,
                                 paste0(wine_name, 
                                       ifelse(is.na(vintage) | vintage == "N.V.", 
                                             "", paste0(" (", vintage, ")")))),
        Producer = ifelse(is.na(winery) | winery == "Various Producers", "Various Producers", winery),
        `Region/Location` = ifelse(is.na(region) | region == "Various Regions", 
                                  ifelse(is.na(country) | country == "Various Countries", "Various", country),
                                  paste0(region, ", ", country)),
        Vintage = ifelse(is.na(vintage) | vintage == "N.V.", "N.V.", as.character(vintage)),
        Price = ifelse(is.na(price) | price == 0, "Price on Request", 
                      paste0('<span class="wine-price">$', format(price, big.mark = ",", nsmall = 2), '</span>')),
        Rating = ifelse(is.na(wine_rating), "Not Rated", 
                       paste0('<span class="wine-rating">', wine_rating, '★</span>')),
        `Pairing Quality` = ifelse(is.na(pairing_quality), "N/A", 
                                 paste0('<span class="pairing-quality">', pairing_quality, '/5 - ', quality_label, '</span>')),
        Category = wine_category,
        `Wine Type` = ifelse(is.na(wine_type), "Various", wine_type),
        `Price Range` = ifelse(is.na(price_range), "Unknown", price_range),
        `Rating Category` = ifelse(is.na(rating_category), "Not Rated", rating_category)
      ) %>%
      select(`Wine & Vintage`, Producer, Vintage, `Region/Location`, Category, `Wine Type`,
             Price, `Price Range`, Rating, `Rating Category`, `Pairing Quality`) %>%
      arrange(desc(parse_number(gsub('<.*?>', '', `Pairing Quality`))), desc(parse_number(gsub('<.*?>', '', Rating))))
    
    DT::datatable(
      display_data,
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        scrollY = "450px",
        order = list(list(10, 'desc')),  # Sort by pairing quality (now column 11, 0-indexed = 10)
        columnDefs = list(
          list(width = "200px", targets = 0),  # Wine & Vintage
          list(width = "150px", targets = 1),  # Producer
          list(width = "80px", targets = 2),   # Vintage
          list(width = "150px", targets = 3),  # Region/Location
          list(width = "100px", targets = 4),  # Category
          list(width = "120px", targets = 5),  # Wine Type
          list(width = "100px", targets = 6),  # Price
          list(width = "120px", targets = 7),  # Price Range
          list(width = "100px", targets = 8),  # Rating
          list(width = "120px", targets = 9),  # Rating Category
          list(width = "150px", targets = 10)  # Pairing Quality
        ),
        dom = 'Bfrtip',
        buttons = c('copy', 'csv', 'excel', 'pdf'),
        searchHighlight = TRUE,
        fixedHeader = TRUE
      ),
      rownames = FALSE,
      class = 'cell-border stripe hover compact',
      escape = FALSE,
      caption = htmltools::tags$caption(
        style = 'caption-side: top; text-align: center; color: #722f37; font-size: 16px; font-weight: bold;',
        paste0('Specific Wine Bottles & Recommendations (', nrow(display_data), ' wines found)')
      )
    )
  })
  
  # Render food results table
  output$food_results <- DT::renderDataTable({
    results <- food_search_results()
    
    if (nrow(results) == 0 || "Message" %in% names(results)) {
      if("Message" %in% names(results)) {
        return(results)
      } else {
        return(data.frame("Status" = "Click Search to find food pairing recommendations"))
      }
    }
    
    # Format the data for display
    display_data <- results %>%
      mutate(
        `Pairing Quality` = ifelse(is.na(pairing_quality), "N/A",
                                 paste('<span class="pairing-quality">', pairing_quality, "/5 -", quality_label, '</span>')),
        `Wine Type` = wine_type,
        `Wine Category` = wine_category,
        `Food Item` = food_name,
        `Food Category` = food_category,
        Cuisine = ifelse(is.na(cuisine), "Various", cuisine)
      )
    
    # Add specific wine info columns only if they exist in the data
    if ("specific_wine_name" %in% names(results)) {
      display_data <- display_data %>%
        mutate(
          `Selected Wine` = ifelse(!is.na(specific_wine_name),
                                 paste0(specific_wine_name, 
                                       ifelse(is.na(specific_vintage) | specific_vintage == "N.V.", "",
                                             paste0(" (", specific_vintage, ")")),
                                       ifelse(is.na(specific_winery), "",
                                             paste0(" - ", specific_winery))),
                                 "All wines of this type"),
          `Wine Details` = ifelse(!is.na(specific_price) & !is.na(specific_rating),
                                 paste0("$", round(specific_price, 2), " - ", round(specific_rating, 1), "★"),
                                 "Various options")
        )
    } else {
      display_data <- display_data %>%
        mutate(
          `Selected Wine` = "All wines of this type",
          `Wine Details` = "Various options"
        )
    }
    
    # Select columns based on whether specific wine was chosen
    if ("specific_wine_name" %in% names(results)) {
      display_data <- display_data %>%
        select(`Selected Wine`, `Wine Details`, `Wine Type`, `Wine Category`, 
               `Food Item`, `Food Category`, Cuisine, `Pairing Quality`)
    } else {
      display_data <- display_data %>%
        select(`Wine Type`, `Wine Category`, `Food Item`, `Food Category`, 
               Cuisine, `Pairing Quality`)
    }
    
    DT::datatable(
      display_data,
      options = list(
        pageLength = 10,
        scrollX = TRUE,
        order = list(list(ncol(display_data)-1, 'desc')),  # Sort by pairing quality (last column minus 1)
        searchHighlight = TRUE
      ),
      rownames = FALSE,
      class = 'cell-border stripe hover',
      escape = FALSE
    )
  })
  
  # Price vs Rating plot
  output$price_rating_plot <- renderPlotly({
    results <- if (input$search_type == "food_to_wine") {
      wine_search_results()
    } else {
      if(nrow(wine_data()$all_wines) > 1000) {
        wine_data()$all_wines %>% slice_sample(n = 1000)  # Sample for performance
      } else {
        wine_data()$all_wines
      }
    }
    
    if (nrow(results) == 0 || "Message" %in% names(results)) {
      return(NULL)
    }
    
    # Filter out rows with missing price or rating data
    results_clean <- results
    
    # Add rating_final column based on what's available
    if ("wine_rating" %in% names(results)) {
      results_clean <- results_clean %>% 
        mutate(rating_final = coalesce(as.numeric(wine_rating), 0))
    } else if ("specific_rating" %in% names(results)) {
      results_clean <- results_clean %>% 
        mutate(rating_final = coalesce(as.numeric(specific_rating), 0))
    } else if ("rating" %in% names(results)) {
      results_clean <- results_clean %>% 
        mutate(rating_final = coalesce(as.numeric(rating), 0))
    } else {
      results_clean <- results_clean %>% 
        mutate(rating_final = 0)
    }
    
    # Handle price column - need to extract numeric value if formatted with $
    results_clean <- results_clean %>%
      mutate(price_final = case_when(
        is.character(price) ~ as.numeric(gsub("\\$", "", price)),
        is.numeric(price) ~ as.numeric(price),
        TRUE ~ NA_real_
      )) %>%
      filter(!is.na(price_final), rating_final > 0, price_final > 0)
    
    # Remove original price column if it exists (always should)
    if ("price" %in% names(results_clean)) {
      results_clean <- results_clean %>% select(-price)
    }
    
    # Remove original rating column if it exists (depends on search type)
    if ("rating" %in% names(results_clean)) {
      results_clean <- results_clean %>% select(-rating)
    }
    
    # Remove wine_rating column if it exists (from food-to-wine search)
    if ("wine_rating" %in% names(results_clean)) {
      results_clean <- results_clean %>% select(-wine_rating)
    }
    
    # Now safely rename the final columns
    results_clean <- results_clean %>%
      rename(rating = rating_final, price = price_final)
    
    if(nrow(results_clean) == 0) {
      return(NULL)
    }
    
    p <- ggplot(results_clean, aes(x = price, y = rating, color = wine_category)) +
      geom_point(alpha = 0.7, size = 2) +
      geom_smooth(method = "lm", se = FALSE, alpha = 0.5) +
      labs(
        title = "Price vs Rating Analysis",
        x = "Price ($)",
        y = "Rating",
        color = "Wine Category"
      ) +
      theme_minimal() +
      theme(legend.position = "bottom")
    
    ggplotly(p)
  })
  
  # Geographic distribution plot  
  output$geographic_plot <- renderPlotly({
    results <- if (input$search_type == "food_to_wine") {
      wine_search_results()
    } else {
      if(nrow(wine_data()$all_wines) > 1000) {
        wine_data()$all_wines %>% slice_sample(n = 1000)
      } else {
        wine_data()$all_wines
      }
    }
    
    if (nrow(results) == 0 || "Message" %in% names(results)) {
      return(NULL)
    }
    
    # Filter and clean data
    results_clean <- results
    
    # Add rating_final column based on what's available
    if ("wine_rating" %in% names(results)) {
      results_clean <- results_clean %>% 
        mutate(rating_final = coalesce(as.numeric(wine_rating), 0))
    } else if ("specific_rating" %in% names(results)) {
      results_clean <- results_clean %>% 
        mutate(rating_final = coalesce(as.numeric(specific_rating), 0))
    } else if ("rating" %in% names(results)) {
      results_clean <- results_clean %>% 
        mutate(rating_final = coalesce(as.numeric(rating), 0))
    } else {
      results_clean <- results_clean %>% 
        mutate(rating_final = 0)
    }
    
    # Handle price column - need to extract numeric value if formatted with $
    results_clean <- results_clean %>%
      mutate(price_final = case_when(
        is.character(price) ~ as.numeric(gsub("\\$", "", price)),
        is.numeric(price) ~ as.numeric(price),
        TRUE ~ NA_real_
      )) %>%
      filter(!is.na(country), rating_final > 0, !is.na(price_final), price_final > 0)
    
    # Remove original price column if it exists (always should)
    if ("price" %in% names(results_clean)) {
      results_clean <- results_clean %>% select(-price)
    }
    
    # Remove original rating column if it exists (depends on search type)
    if ("rating" %in% names(results_clean)) {
      results_clean <- results_clean %>% select(-rating)
    }
    
    # Remove wine_rating column if it exists (from food-to-wine search)
    if ("wine_rating" %in% names(results_clean)) {
      results_clean <- results_clean %>% select(-wine_rating)
    }
    
    # Now safely rename the final columns
    results_clean <- results_clean %>%
      rename(rating = rating_final, price = price_final)
    
    if(nrow(results_clean) == 0) {
      return(NULL)
    }
    
    country_summary <- results_clean %>%
      group_by(country) %>%
      summarise(
        count = n(),
        avg_rating = mean(rating, na.rm = TRUE),
        avg_price = mean(price, na.rm = TRUE),
        .groups = 'drop'
      ) %>%
      top_n(15, count)
    
    p <- ggplot(country_summary, aes(x = reorder(country, count), y = count, fill = avg_rating)) +
      geom_col() +
      coord_flip() +
      labs(
        title = "Wine Distribution by Country",
        x = "Country",
        y = "Number of Wines",
        fill = "Avg Rating"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Quality analysis plot
  output$quality_plot <- renderPlotly({
    results <- if (input$search_type == "food_to_wine") {
      wine_search_results()
    } else {
      wine_data()$pairings %>% slice_sample(n = 1000)
    }
    
    if (nrow(results) == 0) return(NULL)
    
    if ("pairing_quality" %in% names(results)) {
      quality_summary <- results %>%
        group_by(pairing_quality, quality_label) %>%
        summarise(count = n(), .groups = 'drop')
      
      p <- ggplot(quality_summary, aes(x = factor(pairing_quality), y = count, fill = quality_label)) +
        geom_col() +
        labs(
          title = "Pairing Quality Distribution",
          x = "Pairing Quality Score",
          y = "Number of Pairings",
          fill = "Quality Label"
        ) +
        theme_minimal()
    } else {
      rating_summary <- results %>%
        mutate(rating_bin = cut(rating, breaks = seq(0, 5, 0.5), include.lowest = TRUE)) %>%
        group_by(rating_bin) %>%
        summarise(count = n(), .groups = 'drop')
      
      p <- ggplot(rating_summary, aes(x = rating_bin, y = count)) +
        geom_col(fill = "steelblue", alpha = 0.7) +
        labs(
          title = "Wine Rating Distribution",
          x = "Rating Range",
          y = "Number of Wines"
        ) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
    
    ggplotly(p)
  })
  
  # Analytics plots
  output$pairing_overview <- renderPlotly({
    req(wine_data())
    
    category_summary <- wine_data()$pairings %>%
      group_by(wine_category) %>%
      summarise(
        count = n(),
        avg_quality = mean(pairing_quality, na.rm = TRUE),
        .groups = 'drop'
      )
    
    p <- ggplot(category_summary, aes(x = reorder(wine_category, count), y = count, fill = avg_quality)) +
      geom_col() +
      coord_flip() +
      labs(
        title = "Pairings by Wine Category",
        x = "Wine Category",
        y = "Number of Pairings",
        fill = "Avg Quality"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$wine_distribution <- renderPlotly({
    req(wine_data())
    
    wine_summary <- wine_data()$all_wines %>%
      group_by(wine_category) %>%
      summarise(count = n(), .groups = 'drop')
    
    p <- ggplot(wine_summary, aes(x = "", y = count, fill = wine_category)) +
      geom_col() +
      coord_polar("y", start = 0) +
      labs(title = "Wine Categories Distribution", fill = "Category") +
      theme_void()
    
    ggplotly(p)
  })
  
  output$price_analysis <- renderPlotly({
    req(wine_data())
    
    price_data <- wine_data()$all_wines %>%
      filter(!is.na(price)) %>%
      mutate(price_bin = cut(price, breaks = c(0, 15, 30, 60, 100, Inf), 
                            labels = c("$0-15", "$15-30", "$30-60", "$60-100", "$100+")))
    
    p <- ggplot(price_data, aes(x = price_bin, fill = wine_category)) +
      geom_bar(position = "dodge") +
      labs(
        title = "Price Distribution by Category",
        x = "Price Range",
        y = "Number of Wines",
        fill = "Category"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  output$rating_trends <- renderPlotly({
    req(wine_data())
    
    rating_data <- wine_data()$all_wines %>%
      filter(!is.na(rating) & !is.na(year) & year > 2000) %>%
      group_by(year, wine_category) %>%
      summarise(avg_rating = mean(rating, na.rm = TRUE), .groups = 'drop')
    
    p <- ggplot(rating_data, aes(x = year, y = avg_rating, color = wine_category)) +
      geom_line(size = 1) +
      geom_smooth(method = "loess", se = FALSE, alpha = 0.3) +
      labs(
        title = "Average Rating Trends by Year",
        x = "Year",
        y = "Average Rating",
        color = "Category"
      ) +
      theme_minimal()
    
    ggplotly(p)
  })
  
  # Region analysis table
  output$region_analysis <- DT::renderDataTable({
    req(wine_data())
    
    region_data <- wine_data()$all_wines %>%
      group_by(country, region) %>%
      summarise(
        wine_count = n(),
        avg_rating = round(mean(rating, na.rm = TRUE), 2),
        avg_price = round(mean(price, na.rm = TRUE), 2),
        price_range = paste("$", round(min(price, na.rm = TRUE)), "-", round(max(price, na.rm = TRUE))),
        .groups = 'drop'
      ) %>%
      filter(wine_count >= 5) %>%
      arrange(desc(wine_count)) %>%
      head(50)
    
    DT::datatable(
      region_data,
      options = list(pageLength = 15, scrollX = TRUE),
      colnames = c("Country", "Region", "Wine Count", "Avg Rating", "Avg Price ($)", "Price Range"),
      rownames = FALSE
    ) %>%
      DT::formatStyle("avg_rating", 
        backgroundColor = DT::styleInterval(c(3.5, 4.0, 4.5), c("#ffebee", "#fff3e0", "#e8f5e8", "#c8e6c9")))
  })
}

# Include required libraries for plots
library(ggplot2)