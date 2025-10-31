# 🫀 Losanna

> **Cardiorespiratory Synchronization Analysis Platform**  
> Investigating the dynamic coupling between respiratory cycles and cardiac activity, and its modulation by auditory stimuli

[![MATLAB](https://img.shields.io/badge/MATLAB-2025a%20%7C%202019a-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

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
- **Statistical significance markers** for group comparisons

---

## 🔬 Pipeline Workflow

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

The `utils/` folder provides comprehensive tools for development, testing, and data quality assurance:

#### Data Generation & Simulation
| Script | Purpose | Use Case |
|--------|---------|----------|
| `SimulatedSignal.m` | Generate synthetic cardiorespiratory signals with controlled synchronization patterns | Algorithm validation with known ground truth |
| `Create_data.m` | Extract lightweight datasets containing only ECG and respiration channels | Reduce data size for development/sharing |
| `Create_single_sub_data.m` | Extract single subject data for testing and debugging | Quick iteration on algorithm development |

#### Data Loading & Import
| Script | Purpose | Format |
|--------|---------|--------|
| `load_xdf.m` | Import Lab Streaming Layer (LSL) recordings | `.xdf` format |
| `load_xdf_innerloop.mexa64` | Compiled MEX function for accelerated XDF parsing | Binary (Linux x64) |
| `create_raw_data.m` | Function for dataset creation and managing special subjects like 17 | For the Create_data script |
| `analyze_field.m` | Inspect and analyze specific fields within data structures | Data exploration and debugging |

> **Note**: `load_xdf_innerloop.mexa64` is compiled for Linux 64-bit systems. If running on Windows or macOS, you may need to recompile from source or use the pure MATLAB fallback in `load_xdf.m`.

#### Quality Control & Debugging
| Script | Purpose | When to Use |
|--------|---------|-------------|
| `Correpted_identifier.m` | Scan data directories for corrupted, incomplete, or malformed files | Before batch processing to identify problematic recordings |
| `Extract_car_res.m` | Validate preprocessing pipeline on individual subjects with visual feedback | Debug filtering, peak detection, or artifact removal |
| `Extract_sync.m` | Test synchronization detection algorithms with detailed diagnostic plots | Verify m:n ratio detection, phase calculations, or threshold settings |
| `Statistical_analysis.m` | Perform statistical tests and generate summary statistics | Post-processing analysis and hypothesis testing |

---

## 📁 Repository Structure

```
losanna/
│
├── 📄 Start_analysis_server.m       # Batch processing entry point
├── 📄 Aggregate_analysis.m          # Cross-subject statistical analysis
├── 📄 LICENSE                       # Apache 2.0 license file
├── 📄 README.md                     # This documentation file
│
├── 📂 config/                       # Configuration files
│   └── config.json                  # Central JSON configuration for all parameters
│
├── 📂 data/                         # Physiological recordings
│   ├── 📂 awake/                    # Wakefulness condition data
│   └── 📂 sleep/                    # Sleep condition data (staged)
│
├── 📂 log/                          # Analysis execution logs
│   └── analyis_log_<cond>_T<value>_<timestamp>.txt  # Timestamped processing logs
│
├── 📂 output/                       # Analysis results
│   ├── 📂 awake/                    # Wakefulness condition output
│   └── 📂 sleep/                    # Sleep condition output
│
├── 📂 src/                          # Core algorithms
│   ├── 📂 analysis/                 # Synchronization & phase analysis
│   │   ├── create_cycles.m          # Respiratory cycle segmentation
│   │   ├── phase_res.m              # Respiration phase computation
│   │   ├── sync_phase1.m            # Extract possible windows of sync
│   │   ├── sync_phase2.m            # Compute the percentage of sync cycles
│   │   ├── sync_phase3.m            # Auditory event sync cycle stratification
│   │   ├── extract_sound_info.m     # Auditory event parsing
│   │   ├── table_summary.m          # Generate summary statistics tables
│   │   └── table_summary.m~         # Backup file (exclude from version control)
│   │
│   ├── 📂 preprocessing/            # Signal cleaning & filtering
│   │   ├── filter_res_cycles.m      # Respiratory signal filtering
│   │   ├── filter_R_peaks.m         # ECG R-peak filtering
│   │   ├── clean_res_cycles.m       # Respiratory artifact removal
│   │   └── clean_data_find_peaks.m  # Peak detection & QC
│   │
│   └── 📂 graphs/                   # Visualization functions
│       ├── polar_hist_stages.m      # Phase distribution by sleep stage
│       ├── boxplot4stages.m         # Multi-stage boxplot comparisons
│       ├── add_significance_bars.m  # Add statistical significance markers to plots
│       ├── add_significance_bars_grouped.m  # Grouped significance markers
│       ├── bar_sleep.m~             # Backup/temporary file (exclude from version control)
│       ├── bar_single.m             # Single condition bar charts
│       ├── bar_subplot.m            # Multi-panel bar chart layouts
│       └── draw_xregion.m           # Custom shaded regions (2019a compatible)
│
├── 📂 utils/                        # Development & testing tools
│   ├── SimulatedSignal.m            # Synthetic data generator
│   ├── Correpted_identifier.m       # Data integrity checker (typo in filename)
│   ├── Create_data.m                # Create a reduced dataset with ECG, Resp
│   ├── create_raw_data.m            # Generate raw synthetic data files
│   ├── Create_single_sub_data.m     # Extract single subject data for testing
│   ├── Extract_car_res.m            # Preprocessing validation
│   ├── Extract_sync.m               # Synchronization validation
│   ├── Statistical_analysis.m       # Statistical testing utilities
│   ├── analyze_field.m              # Field-level data inspection tool
│   ├── load_xdf.m                   # XDF file format loader (Lab Streaming Layer)
│   └── load_xdf_innerloop.mexa64    # Compiled MEX function for XDF parsing
│
└── 📂 docs/                         # Documentation
    └── DATASET report               # Dataset specification & metadata
```

---

## ⚙️ Configuration

**Losanna** uses a centralized JSON configuration system for flexible parameter management across all analysis scripts. Configuration files are stored in the `config/` directory and allow you to customize:

- Dataset paths and output directories
- Synchronization detection parameters (m:n ratios, thresholds)
- Signal processing settings (sampling rates, filter parameters)
- Experimental conditions (sound types, sleep stages)
- Subject exclusion criteria

### Configuration File Structure

All analysis scripts read parameters from `config/config.json`:

```json
{
  "essential":{ 
    "path_folder": "/mnt/HDD2/piero/Losanna/data/",
    "output_dir": "output/",
    "log_dir": "log/",
    "selected_cond": "sleep",
    "subjects_remove": ["s31"],
    "sync_parameters":{  
      "combinations": ["m1n2", "m1n3", "m1n4", "m1n5", "m1n6", "m2n5", "m2n7"],  
      "T": 30,
      "delta": 5
    }
  },
  
  "conditions": ["sleep", "awake"],
  "number_folder": 2,
  
  "fs": 1024,
  
  "filters_parameter": {
    "RR_window_pks": 20,
    "RR_window_len": 20,
    "sf_res": 0.5,
    "sf_car": 20
  },
  
  "sound_cond": ["nan", "sync", "async", "isoch", "baseline"],
  "sound_codes": [0, 96, 128, 160, 192],
  
  "sleep_stages": ["Awake", "N1", "N2", "N3", "REM"],
  "sleep_score_codes": [0, 1, 2, 3, 4]
}
```

### Parameter Reference

#### Essential Configuration
The `essential` object contains core parameters that must be set for the pipeline to run:

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `path_folder` | string | Absolute path to raw data directory | `"/mnt/HDD2/piero/Losanna/data/"` |
| `output_dir` | string | Directory for analysis results and figures | `"output/"` |
| `log_dir` | string | Directory for analysis logs and processing reports | `"log/"` |
| `selected_cond` | string | Active condition for current analysis | `"sleep"` |
| `subjects_remove` | array | Subject IDs to exclude from batch processing | `["s31"]` |
| `sync_parameters` | object | Synchronization detection settings (nested within essential) | See below |

#### Synchronization Detection (nested in `essential`)
| Parameter | Type | Description | Typical Values |
|-----------|------|-------------|----------------|
| `combinations` | array | m:n synchronization ratios to test | `["m1n3", "m1n4", "m2n7"]` |
| `T` | integer | Minimum segment length (in cycles) for synchronization detection | `10-30` |
| `delta` | integer | Maximum allowed phase deviation (in degrees) for sync classification | `3-7` |

**Synchronization Ratio Notation**: `"m1n3"` → 1 respiratory cycle : 3 R-peaks

#### Dataset Configuration
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `conditions` | array | Available experimental conditions | `["sleep", "awake"]` |
| `number_folder` | integer | Number of nested subdirectories in data structure | `2` |
| `sleep_stages` | array | Sleep stage labels for classification | `["Awake", "N1", "N2", "N3", "REM"]` |
| `sleep_score_codes` | array | Numerical codes corresponding to sleep stages | `[0, 1, 2, 3, 4]` |

#### Signal Processing
| Parameter | Type | Description | Recommended |
|-----------|------|-------------|-------------|
| `fs` | integer | Sampling frequency (Hz) of raw signals | `1024` |
| `RR_window_pks` | integer | Moving window size for R-peak outlier detection (samples) | `20` |
| `RR_window_len` | integer | Window length for RR-interval filtering (samples) | `20` |
| `sf_res` | float | Smoothing factor for respiratory signal filtering | `0.1-1.0` |
| `sf_car` | float | Smoothing factor for cardiac signal filtering | `10-30` |

#### Auditory Stimulation
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `sound_cond` | array | Sound condition labels | `["nan", "sync", "async", "isoch", "baseline"]` |
| `sound_codes` | array | Numerical event codes matching `sound_cond` order | `[0, 96, 128, 160, 192]` |

**Sound Conditions**:
- `nan`: No sound (spontaneous activity)
- `sync`: Sounds synchronized with R peaks
- `async`: Sounds presented asynchronously
- `isoch`: Isochronous rhythmic stimuli
- `baseline`: Pre-stimulus baseline period

#### Quality Control
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `subjects_remove` | array | Subject IDs to exclude from batch processing | `["s31", "s32"]` |

### Usage in Scripts

#### Loading Configuration
```matlab
% Read configuration file
config = jsondecode(fileread('config/config.json'));

% Access essential parameters
path_folder = config.essential.path_folder;
output_dir = config.essential.output_dir;
selected_cond = config.essential.selected_cond;

% Access synchronization parameters (nested in essential)
sync_combos = config.essential.sync_parameters.combinations;
T_value = config.essential.sync_parameters.T;
delta_value = config.essential.sync_parameters.delta;

% Access other parameters
fs = config.fs;
```

### Quick Configuration Examples

#### Testing New Synchronization Ratios
```json
{
  "essential": {
    "path_folder": "/mnt/HDD2/piero/Losanna/data/",
    "output_dir": "output/",
    "log_dir": "log/",
    "selected_cond": "sleep",
    "subjects_remove": [],
    "sync_parameters": {
      "combinations": ["m1n2", "m1n5", "m3n10"],
      "T": 30,
      "delta": 5
    }
  }
}
```

#### Processing Wake Data Only
```json
{
  "essential": {
    "selected_cond": "awake",
    "path_folder": "/mnt/HDD2/piero/Losanna/data/",
    "output_dir": "output/",
    "log_dir": "log/",
    "subjects_remove": [],
    "sync_parameters": {
      "combinations": ["m1n3", "m1n4"],
      "T": 30,
      "delta": 5
    }
  },
  "sleep_stages": ["Awake"]
}
```

#### Strict Synchronization Criteria
```json
{
  "essential": {
    "sync_parameters": {
      "combinations": ["m1n3", "m1n4"],
      "T": 25,
      "delta": 3
    }
  }
}
```

### Configuration Best Practices

1. **Backup Before Editing**: Keep a copy of `config/config_default.json` with standard parameters
2. **Version Control**: Name configuration files descriptively (e.g., `config_pilot_study.json`, `config_main_analysis.json`)
3. **Validation**: Test new parameter sets on a single subject using `Extract_sync.m` before batch processing

### Troubleshooting

**Problem**: Script cannot find configuration file  
**Solution**: Ensure you're running MATLAB from the repository root directory, or use absolute paths in `config.json`

**Problem**: JSON parsing errors  
**Solution**: Validate JSON syntax at [jsonlint.com](https://jsonlint.com) before running scripts

---

**Next Steps**: After configuring parameters, proceed to [Pipeline Workflow](#🔬-pipeline-workflow) to begin analysis.

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
- **Statistical significance testing** across conditions and stages

All figures are automatically saved in high-resolution PNG.

---

## Known BUGs

The bug that are known and should be fixed are:

- **add_significance_bars_grouped** bar are in the wrong position
- **Phase distribution plots** showing preferred coupling angles

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

This project is licensed under the **Apache License 2.0** - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

This project investigates fundamental mechanisms of cardiorespiratory coupling and its modulation by external stimuli, with potential applications in sleep research, autonomic monitoring, and therapeutic intervention design.

---

**Last Updated**: 31 October 2025  
**Version**: 4.6.1
