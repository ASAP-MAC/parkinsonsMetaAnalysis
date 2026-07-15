# Microbiome LODO Classifier - User Guide

## Overview

This implementation provides a complete pipeline for binary classification of microbiome data using neural networks with Leave-One-Dataset-Out (LODO) cross-validation.

## Installation

```bash
pip install -r requirements.txt
```

If you have a GPU and want to use CUDA:
```bash
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
```

## Quick Start

### 1. Prepare Your Data

Your data should be organized as:

- **Abundance data**: DataFrame with samples as rows, taxa as columns (relative abundances 0-1)
- **Labels**: Series with binary labels (0 or 1)
- **Dataset IDs**: Series indicating which dataset/study each sample belongs to

Example:
```python
import pandas as pd

# Load your data
abundance_data = pd.read_csv('microbiome_abundances.csv', index_col=0)
labels = pd.read_csv('labels.csv', index_col=0)['label']
dataset_ids = pd.read_csv('metadata.csv', index_col=0)['dataset']

# Ensure they're aligned
assert len(abundance_data) == len(labels) == len(dataset_ids)
```

### 2. Run LODO Cross-Validation

```python
from microbiome_lodo_classifier import lodo_cross_validation, plot_results

results = lodo_cross_validation(
    data=abundance_data,
    labels=labels,
    dataset_ids=dataset_ids,
    n_epochs=100,
    batch_size=32,
    learning_rate=0.001,
    weight_decay=1e-4,
    prevalence_threshold=0.1
)

# Visualize results
plot_results(results, save_path='lodo_results.png')
```

### 3. Interpret Results

The `results` dictionary contains detailed information for each fold:

```python
for dataset_name, metrics in results.items():
    print(f"\nDataset: {dataset_name}")
    print(f"AUC-ROC: {metrics['test_auc']:.3f}")
    print(f"Accuracy: {metrics['test_accuracy']:.3f}")
    print(f"F1-Score: {metrics['test_f1']:.3f}")
```

## Key Features

### 1. Data Preprocessing

The pipeline automatically handles:

- **Prevalence filtering**: Removes rare taxa (default: present in <10% of samples)
- **CLR transformation**: Centered log-ratio transformation for compositional data
- **Batch correction**: Standardization to reduce batch effects between datasets
- **Train/validation/test splits**: Proper splitting with no data leakage

### 2. Model Architecture

The neural network includes:

- Batch normalization layers (help with batch effects)
- Multiple hidden layers (default: 256 → 128 → 64)
- Dropout regularization (40% dropout rate)
- ReLU activation functions
- Sigmoid output for binary classification

### 3. Training Strategy

- **Class balancing**: Weighted sampling for imbalanced datasets
- **Early stopping**: Prevents overfitting (patience = 15 epochs)
- **Validation monitoring**: Uses 20% of training data for validation
- **Adam optimizer**: With weight decay (L2 regularization)

### 4. Evaluation Metrics

For each held-out dataset:
- AUC-ROC
- Accuracy
- Precision
- Recall
- F1-Score
- Confusion matrix

## Advanced Usage

### Customizing the Model Architecture

```python
from microbiome_lodo_classifier import MicrobiomeClassifier
import torch.nn as nn

# Create custom architecture
class CustomMicrobiomeClassifier(nn.Module):
    def __init__(self, n_features):
        super().__init__()
        self.network = nn.Sequential(
            nn.BatchNorm1d(n_features),
            nn.Linear(n_features, 512),  # Wider network
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.BatchNorm1d(512),
            nn.Linear(512, 256),
            nn.ReLU(),
            nn.Dropout(0.4),
            nn.BatchNorm1d(256),
            nn.Linear(256, 1),
            nn.Sigmoid()
        )
    
    def forward(self, x):
        return self.network(x)
```

### Adjusting Hyperparameters

```python
results = lodo_cross_validation(
    data=abundance_data,
    labels=labels,
    dataset_ids=dataset_ids,
    n_epochs=150,              # More training epochs
    batch_size=64,             # Larger batch size
    learning_rate=0.0005,      # Lower learning rate
    weight_decay=1e-3,         # Stronger L2 regularization
    prevalence_threshold=0.15  # Stricter feature filtering
)
```

### Adding ComBat Batch Correction

For more sophisticated batch correction, you can integrate ComBat:

```python
from combat.pycombat import pycombat
import pandas as pd

def combat_batch_correction(train_data, test_data, train_batches, test_batches):
    """Apply ComBat batch correction."""
    # Combine train and test
    all_data = pd.concat([
        pd.DataFrame(train_data),
        pd.DataFrame(test_data)
    ], axis=0)
    
    all_batches = list(train_batches) + list(test_batches)
    
    # Apply ComBat
    corrected = pycombat(all_data.T, all_batches)
    
    # Split back
    n_train = len(train_data)
    train_corrected = corrected.T.values[:n_train]
    test_corrected = corrected.T.values[n_train:]
    
    return train_corrected, test_corrected
```

## Best Practices

### 1. Data Quality

- **Remove low-quality samples**: Filter samples with very low read counts
- **Check for outliers**: Use PCoA/PCA to identify and investigate outliers
- **Verify labels**: Ensure your binary labels are correctly assigned
- **Document metadata**: Keep detailed metadata about each dataset (sequencing protocol, primers, etc.)

### 2. Feature Selection

- **Prevalence threshold**: Start with 10%, adjust based on your data
- **Taxonomic level**: Consider different taxonomic levels (genus, species, ASV)
- **Feature importance**: After LODO, analyze which features are consistently important

### 3. Model Validation

- **Compare with baselines**: Try Random Forest, Logistic Regression as baselines
- **Check for overfitting**: Large gap between train and validation performance indicates overfitting
- **Evaluate per-dataset**: Some datasets may perform much worse - investigate why
- **Biological interpretation**: Do the important features make biological sense?

### 4. Handling Different Dataset Sizes

If your datasets vary significantly in size:

```python
# Stratified LODO where you can control validation set size
def custom_train_val_split(X_train, y_train, val_fraction=0.2):
    from sklearn.model_selection import train_test_split
    return train_test_split(X_train, y_train, 
                          test_size=val_fraction,
                          stratify=y_train,
                          random_state=42)
```

### 5. Dealing with Very Imbalanced Classes

If one class is much rarer (e.g., 5% vs 95%):

```python
# Use focal loss instead of BCE
import torch.nn.functional as F

class FocalLoss(nn.Module):
    def __init__(self, alpha=0.25, gamma=2):
        super().__init__()
        self.alpha = alpha
        self.gamma = gamma
    
    def forward(self, inputs, targets):
        bce_loss = F.binary_cross_entropy(inputs, targets, reduction='none')
        pt = torch.exp(-bce_loss)
        focal_loss = self.alpha * (1-pt)**self.gamma * bce_loss
        return focal_loss.mean()

# Use in training
criterion = FocalLoss()
```

## Troubleshooting

### Model Not Converging

- Lower the learning rate (try 0.0001)
- Increase batch size
- Reduce model complexity (fewer/smaller hidden layers)
- Check for data quality issues

### Poor Generalization

- Increase dropout rate (try 0.5-0.6)
- Increase weight decay (try 1e-3 or 1e-2)
- Reduce model size
- Ensure proper batch correction
- Check for batch effects in validation data

### Memory Issues

- Reduce batch size
- Use smaller model architecture
- Process datasets sequentially
- Use gradient accumulation

### One Dataset Performs Much Worse

This is common and expected with LODO! Investigate:
- Different population characteristics
- Different technical protocols
- Class distribution differences
- Consider domain adaptation techniques

## Output Files

The script generates:

1. **Console output**: Detailed progress and metrics for each fold
2. **Results dictionary**: Complete results accessible programmatically
3. **Visualization**: Summary plots saved as PNG

## Citation

If you use this code, consider citing:

- PyTorch: https://pytorch.org/
- Scikit-learn: https://scikit-learn.org/
- Your microbiome data source

## Support

For issues or questions:
1. Check the console output for error messages
2. Verify your data format matches the expected structure
3. Try the example data first to ensure installation is correct
4. Review the hyperparameter settings for your specific use case

## Example Complete Workflow

```python
#!/usr/bin/env python3
"""
Complete workflow for microbiome LODO classification
"""

import pandas as pd
from microbiome_lodo_classifier import lodo_cross_validation, plot_results

# 1. Load data
print("Loading data...")
abundance_data = pd.read_csv('my_abundance_data.csv', index_col=0)
labels = pd.read_csv('my_labels.csv', index_col=0)['disease_status']
metadata = pd.read_csv('my_metadata.csv', index_col=0)
dataset_ids = metadata['study_id']

# 2. Quick data check
print(f"Samples: {len(abundance_data)}")
print(f"Features: {abundance_data.shape[1]}")
print(f"Datasets: {dataset_ids.nunique()}")
print(f"Class balance: {labels.value_counts()}")

# 3. Run LODO
print("\nRunning LODO cross-validation...")
results = lodo_cross_validation(
    data=abundance_data,
    labels=labels,
    dataset_ids=dataset_ids,
    n_epochs=100,
    batch_size=32,
    learning_rate=0.001,
    weight_decay=1e-4,
    prevalence_threshold=0.1
)

# 4. Visualize and save
print("\nGenerating visualizations...")
plot_results(results, save_path='my_lodo_results.png')

# 5. Export detailed results
print("\nSaving detailed results...")
summary = pd.DataFrame({
    'Dataset': list(results.keys()),
    'AUC': [r['test_auc'] for r in results.values()],
    'Accuracy': [r['test_accuracy'] for r in results.values()],
    'F1': [r['test_f1'] for r in results.values()],
    'N_test': [r['n_test'] for r in results.values()]
})
summary.to_csv('lodo_summary.csv', index=False)

print("\nDone!")
```
