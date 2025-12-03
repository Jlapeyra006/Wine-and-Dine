## Installation Instructions

### System Requirements
- **R Version**: 4.0 or higher
- **RAM**: Minimum 4GB, 8GB recommended
- **Storage**: 500MB free space
- **Browser**: Chrome, Firefox, Safari, or Edge

### Required R Packages
The application will automatically install missing packages on first run:

```r
# Core Shiny packages
install.packages("shiny")
install.packages("shinydashboard")
install.packages("DT")

# Data manipulation
install.packages("dplyr")
install.packages("readr")
install.packages("stringr")

# Visualization
install.packages("ggplot2")
install.packages("plotly")
```

### Manual Package Installation
If automatic installation fails, run this in R:

```r
required_packages <- c("shiny", "shinydashboard", "DT", "dplyr", 
                      "readr", "stringr", "ggplot2", "plotly")

install.packages(required_packages, dependencies = TRUE)
```

### Running the Application

#### Method 1: RStudio
1. Open RStudio
2. Set working directory: `setwd("/path/to/Wine and Dine v1.0")`
3. Run: `source("app.R")`

#### Method 2: Command Line
```bash
cd "/path/to/Wine and Dine v1.0"
R -e "shiny::runApp('app.R', port = 8080)"
```

#### Method 3: R Console
```r
setwd("/path/to/Wine and Dine v1.0")
shiny::runApp("app.R", port = 8080)
```

### Troubleshooting

#### Common Issues

**Issue**: Package installation fails
**Solution**: 
```r
# Try installing packages individually
install.packages("shiny", repos = "https://cran.r-project.org")
```

**Issue**: Port already in use
**Solution**: Use a different port
```r
shiny::runApp("app.R", port = 8081)
```

**Issue**: Data loading errors
**Solution**: Verify all CSV files are in the `data/` directory

**Issue**: Memory issues with large datasets
**Solution**: Increase R memory limit
```r
memory.limit(size = 8000)  # Windows
# On Mac/Linux, use terminal: ulimit -v 8000000
```

### Performance Tips
- **First Launch**: Initial data loading may take 1-2 minutes
- **Large Datasets**: Consider using data sampling for demo purposes
- **Memory Usage**: Close other applications for optimal performance
- **Browser**: Use Chrome or Firefox for best experience

### Customization
- **Port**: Change port in app.R (default: 8080)
- **Data**: Replace CSV files in `data/` directory with your own
- **Styling**: Modify UI elements in `ui.R`
- **Analysis**: Add new visualizations in `server.R`