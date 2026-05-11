# Microbiome LODO Classifier

A comprehensive implementation of Leave-One-Dataset-Out (LODO) cross-validation for binary classification of microbiome data using neural networks and traditional machine learning methods.

## 📋 Overview

This toolkit provides:

- **Neural Network Classifier** optimized for microbiome compositional data
- **LODO Cross-Validation** for robust generalization assessment
- **Automated Preprocessing** including CLR transformation and batch correction
- **Method Comparison** against Random Forest, Gradient Boosting, Logistic Regression, and SVM
- **Comprehensive Visualization** of results and performance metrics

## 🚀 Quick Start

### Installation

```bash
# Clone or download this repository
cd microbiome-lodo-classifier

# Install dependencies
pip install -r requirements.txt
```

### Basic Usage

```python
from microbiome_lodo_classifier import lodo_cross_validation, plot_results
import pandas as pd

# Load your data
data = pd.read_csv('abundance_data.csv', index_col=0)
labels = pd.read_csv('labels.csv', index_col=0)['label']
dataset_ids = pd.read_csv('metadata.csv', index_col=0)['dataset']

# Run LODO cross-validation
results = lodo_cross_validation(
    data=data,
    labels=labels,
    dataset_ids=dataset_ids
)

# Visualize results
plot_results(results, save_path='results.png')
```

### Run Example Workflow

To see a complete example with simulated data:

```bash
python example_workflow.py
```

This will:
1. Create example microbiome data
2. Run neural network LODO cross-validation
3. Compare with traditional ML methods
4. Generate visualizations and reports

## 📁 Project Structure

```
.
├── microbiome_lodo_classifier.py  # Main neural network implementation
├── model_comparison.py             # Traditional ML comparison utilities
├── example_workflow.py             # Complete example workflow
├── requirements.txt                # Python dependencies
├── USER_GUIDE.md                   # Detailed usage guide
└── README.md                       # This file
```

## 🔧 Key Features

### 1. Robust Preprocessing

- **CLR Transformation**: Handles compositional nature of microbiome data
- **Prevalence Filtering**: Removes rare taxa
- **Batch Correction**: Reduces technical variation between datasets
- **Standardization**: Ensures features are on similar scales

### 2. Neural Network Architecture

- Batch normalization for handling batch effects
- Dropout regularization (40%) to prevent overfitting
- Multiple hidden layers (256 → 128 → 64)
- Weighted sampling for class imbalance
- Early stopping to prevent overfitting

### 3. LODO Cross-Validation

- Proper train/validation/test splitting
- No data leakage between folds
- Per-dataset performance metrics
- Comprehensive evaluation (AUC, accuracy, precision, recall, F1)

### 4. Method Comparison

Automatically compares neural networks against:
- Random Forest
- Gradient Boosting
- Logistic Regression
- Support Vector Machines

## 📊 Example Output

The toolkit generates:

### 1. Neural Network Performance Visualization
- AUC-ROC by dataset
- Performance metrics comparison
- Sample size distribution
- Confusion matrices

### 2. Method Comparison Visualization
- Mean AUC comparison with error bars
- Distribution of AUC across folds
- Multi-metric comparison
- Per-dataset performance heatmap

### 3. Detailed Reports
- Summary statistics for all methods
- Per-dataset performance breakdown
- Recommendations based on results

## 📈 When to Use Neural Networks

Based on your LODO results, you should use neural networks if:

✅ **Use Neural Networks When:**
- You have 1000+ samples
- Neural networks rank #1 in the comparison
- AUC improvement over traditional ML is >0.05
- You need complex feature interactions

❌ **Use Traditional ML When:**
- You have <500 samples
- Traditional ML outperforms neural networks
- You need model interpretability
- Computational resources are limited

## ⚙️ Configuration

### Key Parameters

```python
results = lodo_cross_validation(
    data=data,
    labels=labels,
    dataset_ids=dataset_ids,
    
    # Training parameters
    n_epochs=100,              # Maximum training epochs
    batch_size=32,             # Batch size (16-64 typical)
    learning_rate=0.001,       # Learning rate (0.0001-0.01)
    weight_decay=1e-4,         # L2 regularization (1e-5 to 1e-3)
    
    # Preprocessing
    prevalence_threshold=0.1   # Min prevalence to keep feature (0.05-0.2)
)
```

### Hyperparameter Tuning Tips

**If model is underfitting:**
- Increase model size (more/larger hidden layers)
- Decrease weight_decay
- Increase learning_rate
- Train for more epochs

**If model is overfitting:**
- Increase dropout rate (0.5-0.6)
- Increase weight_decay (1e-3 to 1e-2)
- Reduce model size
- Use stronger batch correction

## 📖 Documentation

See [USER_GUIDE.md](USER_GUIDE.md) for:
- Detailed usage instructions
- Data preparation guidelines
- Advanced configuration options
- Troubleshooting guide
- Best practices

## 🔬 Scientific Background

### Why LODO?

Leave-one-dataset-out cross-validation is crucial for microbiome studies because:

1. **Batch Effects**: Different sequencing centers, protocols, and DNA extraction methods create strong technical variation
2. **Generalization**: Performance within a single dataset often doesn't reflect real-world generalization
3. **Robustness**: LODO reveals which datasets are outliers and need investigation
4. **Publication**: LODO is increasingly required by reviewers for microbiome ML papers

### Why CLR Transformation?

Microbiome data is compositional (relative abundances sum to 1), which creates spurious correlations. CLR transformation addresses this by:
- Removing the unit-sum constraint
- Making data more suitable for standard statistical methods
- Improving machine learning performance

## 🤝 Contributing

Suggestions and improvements are welcome! Common extensions:

- ComBat batch correction integration
- Additional model architectures
- Feature importance analysis
- External validation utilities
- Integration with phylogenetic trees

## 📚 Citation

If you use this code in your research, please cite:

```
Your publication details here
```

## 🐛 Troubleshooting

### Common Issues

**"Model not converging"**
- Reduce learning rate
- Increase batch size
- Check for data quality issues

**"Poor generalization"**
- Increase dropout rate
- Add more regularization
- Check for batch effects
- Consider using fewer features

**"One dataset performs much worse"**
- This is expected and normal in LODO!
- Investigate technical differences
- Check class distribution
- Consider excluding if it's truly an outlier

See USER_GUIDE.md for detailed troubleshooting.

## 📄 License

[Specify your license here]

## 👥 Authors

[Your name/institution]

## 🙏 Acknowledgments

Built with:
- PyTorch
- Scikit-learn
- Pandas
- NumPy
- Matplotlib/Seaborn
