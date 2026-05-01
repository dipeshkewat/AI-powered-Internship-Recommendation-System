"""
Generate comprehensive visualizations for InternMatch project presentation
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import seaborn as sns
from sklearn.metrics import confusion_matrix
import pandas as pd

# Set style
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (14, 8)
plt.rcParams['font.size'] = 11

# ============================================================================
# 1. MODEL ACCURACY COMPARISON
# ============================================================================
def plot_accuracy():
    fig, ax = plt.subplots(figsize=(10, 6))
    
    metrics = ['Training\nAccuracy', 'Test\nAccuracy', 'Macro Avg\nPrecision', 'Macro Avg\nRecall', 'Macro Avg\nF1-Score']
    values = [92.15, 89.92, 90, 89, 90]
    colors = ['#2E86AB', '#A23B72', '#F18F01', '#C73E1D', '#6A994E']
    
    bars = ax.bar(metrics, values, color=colors, alpha=0.8, edgecolor='black', linewidth=2)
    
    # Add value labels on bars
    for bar, val in zip(bars, values):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
                f'{val:.2f}%',
                ha='center', va='bottom', fontsize=12, fontweight='bold')
    
    ax.set_ylim(0, 100)
    ax.set_ylabel('Score (%)', fontsize=12, fontweight='bold')
    ax.set_title('InternMatch ML Model Performance Metrics', fontsize=14, fontweight='bold', pad=20)
    ax.grid(axis='y', alpha=0.3)
    
    # Add target line
    ax.axhline(y=80, color='red', linestyle='--', linewidth=2, alpha=0.5, label='Target (80%)')
    ax.legend()
    
    plt.tight_layout()
    plt.savefig('1_model_accuracy.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: 1_model_accuracy.png")
    plt.close()

# ============================================================================
# 2. CLASS DISTRIBUTION
# ============================================================================
def plot_class_distribution():
    fig, ax = plt.subplots(figsize=(12, 6))
    
    domains = ['App Dev', 'Cloud', 'UI/UX', 'Web', 'AI/ML', 'Cybersecurity', 
               'Data Science', 'DevOps', 'Blockchain', 'Game Dev']
    samples = [1145, 157, 129, 128, 492, 401, 167, 96, 162, 123]
    
    colors = sns.color_palette("husl", len(domains))
    bars = ax.barh(domains, samples, color=colors, edgecolor='black', linewidth=1.5)
    
    # Add value labels
    for i, (bar, val) in enumerate(zip(bars, samples)):
        ax.text(val + 20, i, f'{val}', va='center', fontweight='bold', fontsize=10)
    
    ax.set_xlabel('Number of Training Samples', fontsize=12, fontweight='bold')
    ax.set_title('Training Data Distribution Across 10 Domains', fontsize=14, fontweight='bold', pad=20)
    ax.set_xlim(0, max(samples) + 200)
    
    plt.tight_layout()
    plt.savefig('2_class_distribution.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: 2_class_distribution.png")
    plt.close()

# ============================================================================
# 3. FEATURE IMPORTANCE
# ============================================================================
def plot_feature_importance():
    fig, ax = plt.subplots(figsize=(11, 6))
    
    features = ['Location\nPreference', 'Type\nPreference', 'Interest\nMatch', 
                'CGPA', 'Type\nBinding', 'Location\nBinding',
                'Skill 5', 'Skill 10', 'Skill 11', 'Skill 1']
    importance = [0.1162, 0.1162, 0.1156, 0.1155, 0.0930, 0.0846, 0.0637, 0.0430, 0.0423, 0.0375]
    
    colors = ['#FF6B6B' if imp > 0.10 else '#4ECDC4' for imp in importance]
    bars = ax.bar(range(len(features)), importance, color=colors, edgecolor='black', linewidth=1.5)
    
    # Add value labels
    for bar, val in zip(bars, importance):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
                f'{val:.4f}',
                ha='center', va='bottom', fontsize=10, fontweight='bold')
    
    ax.set_xticks(range(len(features)))
    ax.set_xticklabels(features, fontsize=10)
    ax.set_ylabel('Importance Score', fontsize=12, fontweight='bold')
    ax.set_title('Top 10 Feature Importances in Random Forest Model', fontsize=14, fontweight='bold', pad=20)
    ax.set_ylim(0, max(importance) * 1.15)
    
    plt.tight_layout()
    plt.savefig('3_feature_importance.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: 3_feature_importance.png")
    plt.close()

# ============================================================================
# 4. DOMAIN-WISE PERFORMANCE (F1-SCORES)
# ============================================================================
def plot_domain_performance():
    fig, ax = plt.subplots(figsize=(12, 6))
    
    domains = ['Blockchain', 'Cybersecurity', 'Data Science', 'Game Dev', 'UI/UX', 
               'Web', 'App Dev', 'Cloud', 'AI/ML', 'DevOps']
    f1_scores = [1.00, 1.00, 1.00, 1.00, 0.96, 0.88, 0.86, 0.59, 0.71, 0.69]
    
    colors = ['#2ecc71' if f1 >= 0.90 else '#f39c12' if f1 >= 0.70 else '#e74c3c' for f1 in f1_scores]
    bars = ax.bar(range(len(domains)), f1_scores, color=colors, edgecolor='black', linewidth=1.5)
    
    # Add value labels
    for bar, val in zip(bars, f1_scores):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height - 0.05,
                f'{val:.2f}',
                ha='center', va='top', fontsize=11, fontweight='bold', color='white')
    
    ax.set_xticks(range(len(domains)))
    ax.set_xticklabels(domains, rotation=45, ha='right')
    ax.set_ylabel('F1-Score', fontsize=12, fontweight='bold')
    ax.set_title('Per-Domain Model Performance (F1-Score)', fontsize=14, fontweight='bold', pad=20)
    ax.set_ylim(0, 1.1)
    ax.axhline(y=0.80, color='red', linestyle='--', linewidth=2, alpha=0.5, label='Target (80%)')
    
    # Add legend
    green_patch = mpatches.Patch(color='#2ecc71', label='Excellent (≥90%)')
    orange_patch = mpatches.Patch(color='#f39c12', label='Good (70-90%)')
    red_patch = mpatches.Patch(color='#e74c3c', label='Fair (<70%)')
    ax.legend(handles=[green_patch, orange_patch, red_patch], loc='lower right')
    
    plt.tight_layout()
    plt.savefig('4_domain_performance.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: 4_domain_performance.png")
    plt.close()

# ============================================================================
# 5. TRAINING vs TEST ACCURACY (OVERFITTING CHECK)
# ============================================================================
def plot_train_vs_test():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: Train vs Test Accuracy
    categories = ['Training\nAccuracy', 'Test\nAccuracy']
    accuracies = [92.15, 89.92]
    colors_lr = ['#3498db', '#e74c3c']
    
    bars = ax1.bar(categories, accuracies, color=colors_lr, width=0.6, edgecolor='black', linewidth=2)
    for bar, val in zip(bars, accuracies):
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height - 2,
                f'{val:.2f}%', ha='center', va='top', fontsize=13, fontweight='bold', color='white')
    
    ax1.set_ylim(70, 95)
    ax1.set_ylabel('Accuracy (%)', fontsize=11, fontweight='bold')
    ax1.set_title('Train vs Test Accuracy\n(Generalization Check)', fontsize=12, fontweight='bold')
    ax1.axhline(y=85, color='green', linestyle='--', linewidth=2, alpha=0.5)
    ax1.text(0.5, 85.5, 'Good generalization', ha='center', fontsize=10, style='italic')
    
    # Right: Overfitting Gap
    gap = 92.15 - 89.92
    ax2.bar(['Overfitting Gap'], [gap], color=['#9b59b6'], width=0.4, edgecolor='black', linewidth=2)
    ax2.text(0, gap/2, f'{gap:.2f}%', ha='center', va='center', fontsize=14, fontweight='bold', color='white')
    ax2.set_ylim(0, 5)
    ax2.set_ylabel('Gap (%)', fontsize=11, fontweight='bold')
    ax2.set_title('Overfitting Analysis\n(Lower is better)', fontsize=12, fontweight='bold')
    ax2.text(0, gap + 0.3, '✓ Minimal Overfitting\n(Gap < 5%)', ha='center', fontsize=9, 
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.7))
    
    plt.tight_layout()
    plt.savefig('5_train_vs_test.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: 5_train_vs_test.png")
    plt.close()

# ============================================================================
# 6. DATASET COMPOSITION
# ============================================================================
def plot_dataset_composition():
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(13, 10))
    
    # Dataset Split
    sizes = [1067, 119]
    colors = ['#3498db', '#e74c3c']
    ax1.pie(sizes, labels=['Training (90%)', 'Testing (10%)'], colors=colors, autopct='%1.1f%%',
            startangle=90, textprops={'fontsize': 11, 'weight': 'bold'})
    ax1.set_title('Train-Test Split\n(1186 Samples)', fontsize=12, fontweight='bold')
    
    # Data Sources
    sources = ['User Profiles', 'Internship\nListings']
    counts = [1186, 1719]
    colors = ['#2ecc71', '#f39c12']
    bars = ax2.bar(sources, counts, color=colors, edgecolor='black', linewidth=2)
    for bar, val in zip(bars, counts):
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height/2,
                f'{val}', ha='center', va='center', fontsize=13, fontweight='bold', color='white')
    ax2.set_ylabel('Count', fontsize=11, fontweight='bold')
    ax2.set_title('Data Sources', fontsize=12, fontweight='bold')
    ax2.set_ylim(0, 11000)
    
    # Features per sample
    feature_groups = ['Skills\n(25)', 'CGPA\n(1)', 'Interests\n(10)', 
                     'Location\n(5)', 'Type\n(4)']
    feature_dims = [25, 1, 10, 5, 4]
    colors = ['#e74c3c', '#f39c12', '#f1c40f', '#2ecc71', '#3498db']
    bars = ax3.bar(feature_groups, feature_dims, color=colors, edgecolor='black', linewidth=2)
    for bar, val in zip(bars, feature_dims):
        height = bar.get_height()
        ax3.text(bar.get_x() + bar.get_width()/2., height/2,
                f'{val}', ha='center', va='center', fontsize=11, fontweight='bold', color='white')
    ax3.set_ylabel('Dimensions', fontsize=11, fontweight='bold')
    ax3.set_title('Feature Vector Composition\n(Total: 45 dimensions)', fontsize=12, fontweight='bold')
    ax3.set_ylim(0, 30)
    
    # Model Details
    ax4.axis('off')
    model_info = """
    MODEL SPECIFICATIONS
    ═══════════════════════════════════════
    
    Algorithm:  Random Forest Classifier
    
    Hyperparameters:
    • n_estimators: 300 trees
    • max_depth: 25
    • min_samples_split: 5
    • min_samples_leaf: 2
    • class_weight: balanced
    
    Training Data:
    • Total samples: 1,186
    • Training samples: 1,067 (90%)
    • Test samples: 119 (10%)
    • Classes: 10 domains
    
    Performance:
    • Training Accuracy: 92.15%
    • Test Accuracy: 89.92% ✓
    • Avg F1-Score: 0.87
    """
    
    ax4.text(0.1, 0.95, model_info, transform=ax4.transAxes, fontsize=10,
            verticalalignment='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig('6_dataset_composition.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: 6_dataset_composition.png")
    plt.close()

# ============================================================================
# 7. SYSTEM ARCHITECTURE
# ============================================================================
def plot_architecture():
    fig, ax = plt.subplots(figsize=(14, 8))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    
    # Title
    ax.text(5, 9.5, 'InternMatch System Architecture', fontsize=16, fontweight='bold', ha='center')
    
    # Layer 1: Frontend
    frontends = [
        {'name': 'Flutter App\n(Mobile/Web)', 'x': 1.5, 'color': '#2E86AB'},
        {'name': 'React Admin\nDashboard', 'x': 5, 'color': '#A23B72'},
        {'name': 'Web Portal', 'x': 8.5, 'color': '#F18F01'},
    ]
    
    for fe in frontends:
        rect = mpatches.FancyBboxPatch((fe['x']-0.8, 7.5), 1.6, 1, 
                                       boxstyle="round,pad=0.1", 
                                       edgecolor='black', facecolor=fe['color'], 
                                       alpha=0.8, linewidth=2)
        ax.add_patch(rect)
        ax.text(fe['x'], 8, fe['name'], ha='center', va='center', 
               fontsize=9, fontweight='bold', color='white')
    
    # Arrows from frontend to API
    for fe in frontends:
        ax.arrow(fe['x'], 7.4, 0, -0.6, head_width=0.15, head_length=0.1, fc='black', ec='black')
    
    # Layer 2: API Gateway
    rect = mpatches.FancyBboxPatch((2, 5.5), 6, 0.8, 
                                   boxstyle="round,pad=0.05", 
                                   edgecolor='black', facecolor='#6A994E', 
                                   alpha=0.8, linewidth=2)
    ax.add_patch(rect)
    ax.text(5, 5.9, 'FastAPI Backend (Port 8000)', ha='center', va='center', 
           fontsize=10, fontweight='bold', color='white')
    
    # Arrows from API to services
    ax.arrow(3, 5.4, 0, -0.6, head_width=0.15, head_length=0.1, fc='black', ec='black')
    ax.arrow(5, 5.4, 0, -0.6, head_width=0.15, head_length=0.1, fc='black', ec='black')
    ax.arrow(7, 5.4, 0, -0.6, head_width=0.15, head_length=0.1, fc='black', ec='black')
    
    # Layer 3: Services
    services = [
        {'name': 'ML Model\n(Random Forest)', 'x': 1, 'color': '#C73E1D'},
        {'name': 'Auth Service', 'x': 3.5, 'color': '#1B4965'},
        {'name': 'Recommendation\nEngine', 'x': 6, 'color': '#D62828'},
        {'name': 'Application\nService', 'x': 8.5, 'color': '#003049'},
    ]
    
    for svc in services:
        rect = mpatches.FancyBboxPatch((svc['x']-0.7, 3.8), 1.4, 0.8, 
                                       boxstyle="round,pad=0.05", 
                                       edgecolor='black', facecolor=svc['color'], 
                                       alpha=0.8, linewidth=2)
        ax.add_patch(rect)
        ax.text(svc['x'], 4.2, svc['name'], ha='center', va='center', 
               fontsize=8, fontweight='bold', color='white')
    
    # Arrows from services to database
    for svc in services:
        ax.arrow(svc['x'], 3.7, 0, -0.6, head_width=0.12, head_length=0.08, 
                fc='gray', ec='gray', alpha=0.6)
    
    # Layer 4: Data
    databases = [
        {'name': 'MongoDB\n(Users, Apps)', 'x': 2.5, 'color': '#13A538'},
        {'name': 'ML Artifacts\n(Model, Encoders)', 'x': 5, 'color': '#F77F00'},
        {'name': 'Cache\n(Redis)', 'x': 7.5, 'color': '#DC2F02'},
    ]
    
    for db in databases:
        rect = mpatches.FancyBboxPatch((db['x']-0.8, 1.5), 1.6, 0.7, 
                                       boxstyle="round,pad=0.05", 
                                       edgecolor='black', facecolor=db['color'], 
                                       alpha=0.8, linewidth=2)
        ax.add_patch(rect)
        ax.text(db['x'], 1.85, db['name'], ha='center', va='center', 
               fontsize=8, fontweight='bold', color='white')
    
    # Bottom annotation
    ax.text(5, 0.5, '🔒 Secure | 🚀 Scalable | 🤖 AI-Powered | 📊 Real-Time Analytics', 
           ha='center', fontsize=9, style='italic', 
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.7))
    
    plt.tight_layout()
    plt.savefig('7_architecture.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: 7_architecture.png")
    plt.close()

# ============================================================================
# 8. KEY METRICS SUMMARY
# ============================================================================
def plot_key_metrics():
    fig = plt.figure(figsize=(14, 8))
    gs = fig.add_gridspec(3, 3, hspace=0.4, wspace=0.3)
    
    # Metric cards
    metrics = [
        {'title': 'Model Accuracy', 'value': '89.9%', 'color': '#2ecc71'},
        {'title': 'Training Samples', 'value': '1,186', 'color': '#3498db'},
        {'title': 'Internship Count', 'value': '1,186', 'color': '#e74c3c'},
        {'title': 'Domains', 'value': '15', 'color': '#f39c12'},
        {'title': 'Feature Dims', 'value': '45', 'color': '#9b59b6'},
        {'title': 'F1-Score', 'value': '0.87', 'color': '#1abc9c'},
        {'title': 'Precision', 'value': '87%', 'color': '#34495e'},
        {'title': 'Recall', 'value': '88%', 'color': '#e67e22'},
        {'title': 'Latency', 'value': '<100ms', 'color': '#c0392b'},
    ]
    
    positions = [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (1, 2), (2, 0), (2, 1), (2, 2)]
    
    for metric, pos in zip(metrics, positions):
        ax = fig.add_subplot(gs[pos[0], pos[1]])
        ax.set_xlim(0, 10)
        ax.set_ylim(0, 10)
        ax.axis('off')
        
        # Card background
        rect = mpatches.FancyBboxPatch((0.5, 2), 9, 6.5, 
                                       boxstyle="round,pad=0.3", 
                                       edgecolor='black', facecolor=metric['color'], 
                                       alpha=0.15, linewidth=2)
        ax.add_patch(rect)
        
        # Title
        ax.text(5, 7, metric['title'], ha='center', va='top', 
               fontsize=10, fontweight='bold')
        
        # Value
        ax.text(5, 4.5, metric['value'], ha='center', va='center', 
               fontsize=16, fontweight='bold', color=metric['color'])
    
    # Main title
    fig.suptitle('InternMatch Project - Key Performance Indicators', 
                fontsize=16, fontweight='bold', y=0.98)
    
    plt.savefig('8_key_metrics.png', dpi=300, bbox_inches='tight')
    print("✓ Saved: 8_key_metrics.png")
    plt.close()

# ============================================================================
# GENERATE ALL PLOTS
# ============================================================================
def main():
    print("=" * 70)
    print("INTERNMATCH PROJECT - VISUALIZATION GENERATION")
    print("=" * 70)
    
    print("\nGenerating visualizations for PowerPoint presentation...\n")
    
    plot_accuracy()
    plot_class_distribution()
    plot_feature_importance()
    plot_domain_performance()
    plot_train_vs_test()
    plot_dataset_composition()
    plot_architecture()
    plot_key_metrics()
    
    print("\n" + "=" * 70)
    print("✅ ALL VISUALIZATIONS GENERATED SUCCESSFULLY!")
    print("=" * 70)
    print("\nFiles created:")
    print("  1. 1_model_accuracy.png - Overall accuracy metrics")
    print("  2. 2_class_distribution.png - Training data distribution")
    print("  3. 3_feature_importance.png - Top features influencing predictions")
    print("  4. 4_domain_performance.png - Per-domain F1-scores")
    print("  5. 5_train_vs_test.png - Generalization and overfitting analysis")
    print("  6. 6_dataset_composition.png - Data details and model specs")
    print("  7. 7_architecture.png - System architecture diagram")
    print("  8. 8_key_metrics.png - KPI summary dashboard")
    print("\n💡 Use these images in your PowerPoint presentation!")
    print("=" * 70)

if __name__ == "__main__":
    main()
