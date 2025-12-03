# Wine and Dine v1.0 - Project Structure

## 📁 Root Directory
```
Wine and Dine v1.0/
├── README.md                    # Main project documentation
├── INSTALL.md                   # Installation instructions
├── LICENSE                      # MIT license
├── CONTRIBUTING.md              # Contribution guidelines
├── .gitignore                   # Git ignore patterns
├── app.R                        # Main application launcher
├── ui.R                         # User interface definition
├── server.R                     # Server-side logic
├── wine_data_loader.R           # Data loading and preprocessing
├── wine_database.dbml           # Database schema (ERD)
└── data/                        # Data directory
```

## 📊 Data Directory Structure
```
data/
├── wine_food_pairings.csv       # Main pairing dataset (34,933 entries)
├── wine_food_pairings 2.csv     # Backup/alternative dataset
├── archive (3)/                 # Wine catalog data
│   ├── Red.csv                  # Red wine catalog (8,666 entries)
│   ├── White.csv                # White wine catalog (3,764 entries)
│   ├── Rose.csv                 # Rosé wine catalog (397 entries)
│   ├── Sparkling.csv            # Sparkling wine catalog (1,007 entries)
│   └── Varieties.csv            # Wine variety information
├── archive (4)/                 # Additional datasets
│   ├── wine_food_pairings.csv   # Alternative pairing data
│   └── winequality-red.csv      # Wine quality dataset
└── archive (5)/                 # Wine review data
    ├── winemag-data_first150k.csv
    ├── winemag-data-130k-v2.csv # Main review dataset (130k entries)
    └── winemag-data-130k-v2.json
```

## 🔧 Core Application Files

### app.R
- **Purpose**: Application entry point and configuration
- **Key Functions**: Package loading, app initialization, port configuration
- **Size**: ~350 bytes

### ui.R  
- **Purpose**: User interface layout and design
- **Key Components**: Navigation, search forms, data tables, analysis plots
- **Framework**: Shiny Dashboard with responsive design
- **Size**: ~12KB

### server.R
- **Purpose**: Backend logic and data processing
- **Key Functions**: Search algorithms, data filtering, plot generation
- **Features**: Real-time search, smart deduplication, error handling
- **Size**: ~32KB

### wine_data_loader.R
- **Purpose**: Data loading and preprocessing pipeline
- **Key Functions**: CSV reading, data cleaning, wine categorization
- **Features**: Price range classification, rating normalization
- **Size**: ~7KB

### wine_database.dbml
- **Purpose**: Database schema and entity relationships
- **Format**: DBML (Database Markup Language)
- **Content**: 15 tables with comprehensive wine and food mappings
- **Size**: ~14KB

## 📚 Documentation Files

### README.md
- Complete project overview and quick start guide
- Feature descriptions and usage examples
- Architecture overview and technical details

### INSTALL.md
- Detailed installation instructions
- System requirements and dependencies
- Troubleshooting guide and performance tips

### CONTRIBUTING.md
- Development guidelines and contribution process
- Code style standards and testing requirements
- Community guidelines and recognition system

### LICENSE
- MIT License for open-source distribution
- Data attribution and usage guidelines

## 🗄️ Data Schema Overview

### Main Tables
1. **Wine Pairings** (34,933 records)
   - Food items, wine types, cuisines, pairing quality scores

2. **Wine Catalog** (13,834 specific wines)
   - Names, producers, vintages, regions, prices, ratings

3. **Wine Reviews** (130,000 professional reviews)
   - Detailed tasting notes, scores, price points

### Key Relationships
- **One-to-Many**: Food categories → Food items
- **Many-to-Many**: Wines ↔ Food pairings
- **One-to-Many**: Wine regions → Specific wines

## 🚀 Deployment Ready Features

### Git Integration
- Comprehensive `.gitignore` for R projects
- Clean repository structure for GitHub hosting
- Documentation for contributors and users

### Scalability
- Modular code architecture
- Efficient data processing
- Performance optimizations for large datasets

### Maintenance
- Clear file organization
- Comprehensive error handling
- Detailed code documentation

## 📈 Data Statistics

| Component | Count | Size |
|-----------|--------|------|
| Wine-Food Pairings | 34,933 | ~3.3MB |
| Specific Wine Bottles | 13,834 | ~2.1MB |
| Wine Reviews | 130,000 | ~55MB |
| Food Categories | 12 | - |
| Wine Types | 29 | - |
| Cuisines | Multiple | - |

## 🔍 File Dependencies

```
app.R
├── ui.R
├── server.R
└── wine_data_loader.R
    └── data/
        ├── wine_food_pairings.csv
        ├── archive (3)/*.csv
        ├── archive (4)/*.csv
        └── archive (5)/*.csv
```

This structure ensures the application is:
- ✅ **Ready for GitHub** hosting and collaboration
- ✅ **Easy to install** with clear instructions
- ✅ **Well documented** for users and developers
- ✅ **Professionally organized** with industry standards
- ✅ **Scalable** for future enhancements