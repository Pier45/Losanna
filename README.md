# 🫀 Losanna

> **Cardiorespiratory Synchronization Analysis Platform**  
> Investigating the dynamic coupling between respiratory cycles and cardiac activity, and its modulation by auditory stimuli

[![MATLAB](https://img.shields.io/badge/MATLAB-2025a%20%7C%202019a-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/license-TBD-blue.svg)](LICENSE)

---

## 📖 About

**Losanna** is a comprehensive analysis framework designed to explore the intricate relationship between breathing and heartbeat rhythms. The platform investigates **cardiorespiratory synchronization** (CRS)—the coordinated timing between respiratory cycles and R-peaks in ECG signals—and examines how external **auditory stimuli** can influence this physiological coupling.

### Key Research Questions

- How synchronized are respiratory cycles with cardiac activity during different sleep stages?
- Does cardiorespiratory coupling differ between wakefulness and various sleep stages?
- Can auditory events modulate the degree of synchronization between breathing and heartbeat?

The toolkit processes multi-modal physiological recordings collected during both **awake** and **sleep** conditions, providing robust metrics for quantifying phase relationships and synchronization patterns.

---

## 🎯 Core Features

### Signal Processing
- **Advanced preprocessing pipeline** for ECG and respiratory signal denoising
- **Automated peak detection** with outlier removal and quality control
- **Memory-efficient processing** using MATLAB's [`matfile`](https://ch.mathworks.com/help/matlab/ref/matlab.io.matfile.html) for large datasets (>2GB, HDF5-based v7.3 format)

### Synchronization Analysis
- **Phase-based coupling detection** between respiratory cycles and R-peaks
- **Flexible synchronization ratios**: configurable m:n patterns (e.g., 2 breaths : 7 heartbeats)
- **Segment-wise analysis** to identify synchronization
- **Multi-stage comparison** across wake, NREM, and REM sleep states

### Auditory Modulation
- **Event-triggered analysis** examining synchronization before, during, and after sound presentation
- **Time-resolved modulation metrics** to capture dynamic changes in coupling strength
- **Statistical comparison** of auditory effects across conditions

### Visualization & Reporting
- **Polar histograms** showing phase distribution across sleep stages
- **Aggregated statistics** with boxplots and bar charts

---

## 🔬 Pipeline Workflow Start_server_analysis

### 1️⃣ **Preprocessing & Feature Extraction**

Clean and prepare physiological signals for analysis:
- Bandpass filtering to remove baseline drift and high-frequency noise
- Artifact detection and removal
- Respiratory cycle boundary identification
- R-peak extraction from ECG with adaptive thresholding

**Quick Start**: Use `Extract_car_res.m` for single-subject preprocessing validation

### 2️⃣ **Synchronization Detection**

Quantify phase relationships between breathing and cardiac cycles:
- Calculate instantaneous phase for each respiratory cycle
- Determine R-peak phases relative to breathing rhythm
- Identify synchronized segments using configurable m:n ratios
- Compute synchronization indices (duration, consistency, phase coherence)

**Quick Start**: Use `Extract_sync.m` to test synchronization algorithms on individual subjects

### 3️⃣ **Auditory Modulation Analysis**

Assess how sound stimuli affect cardiorespiratory coupling:
- Parse auditory event markers via `extract_sound_info.m`
- Window analysis: baseline (pre-sound), stimulus (during), recovery (post-sound)
- Compare synchronization metrics across temporal windows
- Statistical testing for sound-induced changes

### 4️⃣ **Batch Processing & Aggregation**

Scale analysis across multiple subjects and conditions:
- **Server execution**: `Start_analysis_server.m` processes entire datasets in parallel
- **Cross-subject statistics**: `Aggregate_analysis.m` combines results across m:n combinations
- **Group-level visualizations**: sleep stage comparisons, sound block effects

---

## 🛠️ Usage Guide

### Prerequisites

- MATLAB **R2025a** (recommended) or **R2019a** (with compatibility patches)
- Signal Processing Toolbox
- Statistics and Machine Learning Toolbox

### Running the Analysis

#### Single Subject Analysis
```matlab
% Preprocess and extract features
Extract_car_res  % Interactive: select subject file

% Compute synchronization
Extract_sync     % Requires preprocessed data from previous step
```

#### Batch Processing (Server)
```matlab
% Process all subjects in data/awake and data/sleep
Start_analysis_server
```

#### Aggregate Results
```matlab
% Generate cross-subject statistics and figures
Aggregate_analysis
```

### Testing & Validation

The toolkit includes utilities for algorithm validation:

| Script | Purpose |
|--------|---------|
| `utils/SimulatedSignal.m` | Generate synthetic CRS data with known synchronization patterns |
| `utils/CorruptedIdentification.m` | Scan raw data folders for corrupted or incomplete files |
| `utils/Extract_car_res.m` | Validate preprocessing on individual subjects |
| `utils/Extract_sync.m` | Debug synchronization detection algorithms |

---

## 📁 Repository Structure

```
losanna/
│
├── 📄 Start_analysis_server.m       # Batch processing entry point
├── 📄 Aggregate_analysis.m          # Cross-subject statistical analysis
├── 📄 Extract_car_res.m             # Single-subject preprocessing
├── 📄 Extract_sync.m                # Single-subject synchronization
├── 📄 Correpted_recovery.m          # Recovery analysis for corrupted data
│
├── 📂 data/                         # Physiological recordings
│   ├── 📂 awake/                    # Wakefulness condition data
│   └── 📂 sleep/                    # Sleep condition data (staged)
│
├── 📂 src/                          # Core algorithms
│   ├── 📂 analysis/                 # Synchronization & phase analysis
│   │   ├── create_cycles.m          # Respiratory cycle segmentation
│   │   ├── phase_R.m                # R-peak phase computation
│   │   ├── sync_phase1.m            # Coarse sync detection
│   │   ├── sync_phase2.m            # Refined sync detection
│   │   ├── sync_phase3.m            # Final sync classification
│   │   └── extract_sound_info.m     # Auditory event parsing
│   │
│   ├── 📂 preprocessing/            # Signal cleaning & filtering
│   │   ├── filter_breathing_cycles.m    # Respiratory signal filtering
│   │   ├── filter_R_peaks.m             # ECG R-peak filtering
│   │   ├── clean_breathing_cycles.m     # Respiratory artifact removal
│   │   └── clean_data_find_peaks.m      # Peak detection & QC
│   │
│   └── 📂 graphs/                   # Visualization functions
│       ├── polar_hist_stages.m      # Phase distribution by sleep stage
│       ├── boxplot4stages.m         # Multi-stage boxplot comparisons
│       ├── bar_sleep.m              # Bar charts for sleep metrics
│       └── draw_xregion.m           # Custom shaded regions (2019a compatible)
│
├── 📂 utils/                        # Development & testing tools
│   ├── SimulatedSignal.m            # Synthetic data generator
│   ├── CorruptedIdentification.m    # Data integrity checker
│   ├── Extract_car_res.m            # Preprocessing validation
│   └── Extract_sync.m               # Synchronization validation
│
└── 📂 docs/                         # Documentation
    └── DATASET report               # Dataset specification & metadata
```

---

## ⚙️ Configuration

Synchronization detection can be tuned via m:n ratio vectors:

```matlab
% Example: Test 1:3, 1:4, and 2:7 synchronization patterns
combinations = {'m1n3', 'm1n4', 'm2n7'};

% Process each combination
for i = 1:length(combinations)
    ...
end
```

Common physiological ratios:
- **1:3** – Typical resting state (20 breaths/min, 60 bpm)
- **1:4** – Relaxed breathing (15 breaths/min, 60 bpm)
- **2:7** – Deep sleep patterns

---

## 🧪 Compatibility Notes

### MATLAB Version Support

| Feature | R2025a | R2019a |
|---------|--------|--------|
| Core analysis | ✅ Full | ✅ Full |
| `xregion` shading | ✅ Native | ⚠️ Custom implementation |
| `xline` with cell arrays | ✅ Native | ⚠️ Patched workaround |
| Parallel processing | ✅ Optimized | ✅ Basic |

**Migration Notes**: When using R2019a, custom compatibility functions in `src/graphs/` replace missing features. No user action required.

---

## 📊 Example Results

The analysis generates comprehensive outputs including:

- **Synchronization percentage** across sleep stages (Wake, N1, N2, N3, REM)
- **Phase distribution plots** showing preferred coupling angles
- **Sound modulation effects** with pre/during/post comparisons
- **Subject-level reports** with quality metrics and artifact logs

All figures are automatically saved in publication-ready format (high-resolution PNG).

---

## 🤝 Contributing

Contributions are welcome! Please feel free to:
- Report bugs or data processing issues
- Suggest new synchronization metrics
- Improve documentation
- Add visualization options

---

## 📬 Contact

**Principal Investigator**: Piero Policastro
📧 Email: [piero.policastro@gmail.com](mailto:piero.policastro@gmail.com)

For bug reports or technical questions, please open an issue on the repository.

---

## 📄 License

License information coming soon.

---

## 🙏 Acknowledgments

This project investigates fundamental mechanisms of cardiorespiratory coupling and its modulation by external stimuli, with potential applications in sleep research, autonomic monitoring, and therapeutic intervention design.

---

**Last Updated**: October 2025
**Version**: 4.5.0



