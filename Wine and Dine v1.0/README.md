# Wine and Dine v1.0 🍷🍽️

An interactive R Shiny web application for exploring wine and food pairings with comprehensive data analysis capabilities.

## 🌟 Features

### Interactive Search Functionality
- **Food-to-Wine Search**: Find the perfect wines for your favorite dishes
- **Wine-to-Food Search**: Discover ideal food pairings for specific wines
- **Advanced Filtering**: Filter by cuisine, price range, wine rating, and pairing quality

### Comprehensive Wine Database
- **34,933 wine-food pairings** across multiple cuisines
- **13,834 specific wine bottles** with detailed information
- **4 price categories**: Budget ($0-15), Mid-range ($15-30), Premium ($30-60), Luxury ($60+)
- **Professional wine ratings** and detailed tasting notes

### Data Analysis & Visualization
- **Price vs Rating Analysis**: Interactive scatter plots with trend lines
- **Geographic Distribution**: Wine origin mapping and regional analysis
- **Wine Distribution Charts**: Category and price range breakdowns
- **Smart Deduplication**: Intelligent handling of duplicate entries

### User-Friendly Interface
- **Responsive Design**: Clean, modern dashboard interface
- **Real-time Search**: Instant results as you type and filter
- **Detailed Information**: Complete wine details including producer, vintage, region, and price
- **Professional Formatting**: USD currency display and star ratings

## 🚀 Quick Start

### Prerequisites
- R (version 4.0 or higher)
- Required R packages (automatically installed on first run):
  - `shiny`
  - `shinydashboard`
  - `DT`
  - `dplyr`
  - `ggplot2`
  - `plotly`

### Installation & Running

1. **Clone or download this repository**
   ```bash
   git clone [repository-url]
   cd "Wine and Dine v1.0"
   ```

2. **Launch the application**
   ```r
   # Option 1: Run from R console
   source("app.R")
   
   # Option 2: Run from command line
   R -e "shiny::runApp('app.R', port = 8080, host = '0.0.0.0')"
   ```

3. **Access the application**
   - Open your web browser
   - Navigate to: `http://localhost:8080`
   - Enjoy exploring wine and food pairings!

## 📊 Data Sources

### Wine Catalogs
- **Red Wines**: 8,666 entries with detailed tasting notes
- **White Wines**: 3,764 premium selections
- **Rosé Wines**: 397 diverse options
- **Sparkling Wines**: 1,007 celebration-worthy choices

### Food Categories
- **12 distinct food categories**: From appetizers to desserts
- **38 specific food items**: Carefully curated selection
- **29 wine types**: Comprehensive varietal coverage
- **Multiple cuisines**: International flavor profiles

## 🏗️ Application Architecture

### Core Components
- **`app.R`**: Main application launcher
- **`ui.R`**: User interface definition and layout
- **`server.R`**: Backend logic and data processing
- **`wine_data_loader.R`**: Data loading and preprocessing
- **`wine_database.dbml`**: Entity-relationship diagram

### Data Structure
```
data/
├── wine_food_pairings.csv          # Main pairing dataset
├── archive (3)/                    # Wine catalog files
│   ├── Red.csv
│   ├── White.csv
│   ├── Rose.csv
│   └── Sparkling.csv
├── archive (4)/                    # Additional datasets
└── archive (5)/                    # Wine magazine reviews
```

## 🔧 Technical Features

### Advanced Data Processing
- **Smart Wine Matching**: Intelligent categorization algorithm
- **Price Range Classification**: Automatic budget categorization
- **Rating Normalization**: Standardized scoring system
- **Deduplication Logic**: Prevents redundant entries

### Performance Optimization
- **Efficient Data Loading**: Optimized CSV processing
- **Memory Management**: Smart data sampling for large datasets
- **Responsive UI**: Fast search and filtering
- **Error Handling**: Robust error management and user feedback

### Search Capabilities
- **Multi-dimensional Filtering**: Combine multiple search criteria
- **Real-time Updates**: Dynamic dropdown population
- **Fuzzy Matching**: Flexible search algorithms
- **Result Ranking**: Quality-based sorting

## 📈 Usage Examples

### Finding Wine for Food
1. Select "Food to Wine" search type
2. Choose a food item (e.g., "Grilled Salmon")
3. Optional: Apply cuisine filter (e.g., "Mediterranean")
4. Review wine recommendations with ratings and prices
5. Explore price/rating analysis in the detailed analysis tab

### Finding Food for Wine
1. Select "Wine to Food" search type
2. Choose wine category (e.g., "Red Wine")
3. Select specific wine type (e.g., "Pinot Noir")
4. Optional: Choose a specific wine bottle
5. Discover perfect food pairings with quality scores

## 🎯 Key Improvements (v1.0)

### Search Functionality
- ✅ Fixed `[object Object]` display errors
- ✅ Implemented proper USD currency formatting
- ✅ Added wine diversity across all price ranges
- ✅ Enhanced specific wine selection capabilities

### Data Analysis
- ✅ Working price vs. rating scatter plots
- ✅ Geographic distribution mapping
- ✅ Interactive data visualization
- ✅ Robust error handling for different data structures

### User Experience
- ✅ Responsive design improvements
- ✅ Professional wine information display
- ✅ Intelligent deduplication system
- ✅ Enhanced search performance

## 📝 Version History

### v1.0 (Current)
- Complete application with working analysis plots
- Comprehensive wine database integration
- Professional-grade user interface
- Full GitHub repository preparation

### Previous Versions
- v0.1-0.9: Development iterations with progressive feature additions

## 🤝 Contributing

We welcome contributions! Please feel free to:
- Report bugs or suggest improvements
- Submit pull requests for new features
- Share your wine and food pairing discoveries
- Contribute additional datasets

## 📄 License

This project is available for educational and personal use. Please respect data source attributions and contribute back to the community.

## 🙏 Acknowledgments

- Wine data sourced from multiple professional wine databases
- Food pairing expertise from culinary professionals
- R Shiny community for excellent framework and packages
- Contributors who helped test and improve the application

## 📞 Support

For questions, issues, or suggestions:
- Create an issue in this repository
- Check the documentation for common solutions
- Review the code comments for implementation details

---

**Enjoy your wine and dining discoveries!** 🥂✨