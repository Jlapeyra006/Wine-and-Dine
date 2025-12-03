# Contributing to Wine and Dine

We love your input! We want to make contributing to Wine and Dine as easy and transparent as possible.

## Development Process

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test thoroughly**
5. **Commit changes**: `git commit -m 'Add amazing feature'`
6. **Push to branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

## Types of Contributions

### 🐛 Bug Reports
- Use GitHub Issues to report bugs
- Include R version, operating system, and browser information
- Provide reproducible examples
- Include error messages and screenshots if applicable

### 💡 Feature Requests
- Use GitHub Issues to suggest new features
- Explain the use case and expected behavior
- Provide mockups or examples if helpful

### 📊 Data Contributions
- New wine datasets are welcome
- Ensure data is properly sourced and attributed
- Follow the existing CSV format structure
- Include data source documentation

### 🎨 UI/UX Improvements
- Design improvements are always appreciated
- Maintain accessibility standards
- Test across different screen sizes
- Consider user experience for wine enthusiasts and casual users

### 📝 Documentation
- Help improve README, installation guides, or code comments
- Add examples and use cases
- Translate documentation to other languages

## Code Style

### R Code Standards
```r
# Use meaningful variable names
wine_data_clean <- process_wine_data(raw_data)

# Add comments for complex logic
# Calculate price categories based on quartiles
price_ranges <- calculate_price_categories(wines$price)

# Use consistent indentation (2 spaces)
if (condition) {
  do_something()
} else {
  do_something_else()
}
```

### Shiny Best Practices
- Keep UI and Server logic separate
- Use reactive expressions for expensive computations
- Handle errors gracefully with `tryCatch()`
- Provide user feedback during long operations

## Testing

### Before Submitting
- Test all search functionality (food-to-wine and wine-to-food)
- Verify data visualizations work correctly
- Check responsive design on different screen sizes
- Ensure error handling works properly

### Test Data
- Use the provided sample datasets
- Test with edge cases (empty searches, invalid inputs)
- Verify performance with large datasets

## Pull Request Process

1. **Update Documentation**: Include relevant documentation changes
2. **Test Coverage**: Ensure your changes are tested
3. **Code Review**: Be responsive to feedback
4. **Merge Requirements**: All tests must pass

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Tested locally
- [ ] All search functions work
- [ ] Data visualizations display correctly
- [ ] No console errors

## Screenshots
(If applicable)
```

## Data Guidelines

### Wine Data Format
```csv
name,winery,year,country,region,price,rating,wine_category
"Cabernet Sauvignon","Example Winery",2020,"USA","Napa Valley",45.99,4.2,"Red"
```

### Food Pairing Format
```csv
wine_type,food_item,food_category,cuisine,pairing_quality,description
"Pinot Noir","Grilled Salmon","Seafood","French",4.5,"Classic pairing with earthy undertones"
```

## Community

### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers learn and contribute
- Celebrate diverse perspectives on wine and food

### Getting Help
- Check existing Issues and Pull Requests first
- Use clear, descriptive titles
- Provide context and examples
- Be patient and respectful

## Recognition

Contributors will be recognized in:
- README contributors section
- Release notes for significant contributions
- Special thanks for major features or bug fixes

Thank you for contributing to Wine and Dine! 🍷✨