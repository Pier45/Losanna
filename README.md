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
│
├── 📂 data/                         # Physiological recordings
│   ├── 📂 awake/                    # Wakefulness condition data
│   └── 📂 sleep/                    # Sleep condition data (staged)
│
├── 📂 src/                          # Core algorithms
│   ├── 📂 analysis/                 # Synchronization & phase analysis
│   │   ├── create_cycles.m          # Respiratory cycle segmentation
│   │   ├── phase_res.m              # Respiration phase computation
│   │   ├── sync_phase1.m            # Extract possible windows of sync
│   │   ├── sync_phase2.m            # Compute the percentage of sync cycles
│   │   ├── sync_phase3.m            # Auditory event sync cycle stratification
│   │   └── extract_sound_info.m     # Auditory event parsing
│   │
│   ├── 📂 preprocessing/            # Signal cleaning & filtering
│   │   ├── filter_res_cycles.m      # Respiratory signal filtering
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
│   ├── Corrupted_identifier.m       # Data integrity checker
│   ├── Extract_car_res.m            # Preprocessing validation
│   └── Extract_sync.m               # Synchronization validation
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
  "path_folder": "/mnt/HDD2/CardioAudio_sleepbiotech/data/sleep/",
  "number_folder": 2,
  "data_path": "data/sleep",
  "output_dir": "output/",
  
  "conditions": ["sleep", "awake"],
  "selected_cond": "sleep",
  
  "sync_parameters": {
    "combinations": ["m1n2", "m1n3", "m1n4", "m1n5", "m1n6", "m2n5", "m2n7"],
    "T": 15,
    "delta": 5
  },
  
  "fs": 1024,
  
  "filters_parameter": {
    "RR_window_pks": 20,
    "RR_window_len": 20,
    "sf_res": 0.5,
    "sf_car": 20
  },
  
  "sound_cond": ["nan", "sync", "async", "isoc", "baseline"],
  "sound_codes": [0, 96, 160, 128, 192],
  
  "sleep_stages": ["Awake", "REM", "n1", "n2", "n3"],
  
  "subjects_remove": ["s31", "s32"]
}
```

### Parameter Reference

#### Dataset Configuration
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `path_folder` | string | Absolute path to raw data directory | `"/mnt/HDD2/CardioAudio_sleepbiotech/data/sleep/"` |
| `number_folder` | integer | Number of nested subdirectories in data structure | `2` |
| `data_path` | string | Relative path to data folder | `"data/sleep"` |
| `output_dir` | string | Directory for analysis results and figures | `"output/"` |

#### Experimental Conditions
| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `conditions` | array | Available experimental conditions | `["sleep", "awake"]` |
| `selected_cond` | string | Active condition for current analysis | `"sleep"` |
| `sleep_stages` | array | Sleep stage labels for classification | `["Awake", "REM", "n1", "n2", "n3"]` |

#### Synchronization Detection
| Parameter | Type | Description | Typical Values |
|-----------|------|-------------|----------------|
| `combinations` | array | m:n synchronization ratios to test | `["m1n3", "m1n4", "m2n7"]` |
| `T` | integer | Minimum segment length (in cycles) for synchronization detection | `10-20` |
| `delta` | integer | Maximum allowed phase deviation (in degrees) for sync classification | `3-10` |

**Synchronization Ratio Notation**: `"m1n3"` → 1 respiratory cycle : 3 R-peaks

**Common Physiological Patterns**:
- **m1n3**: Typical resting state (20 breaths/min, 60 bpm)
- **m1n4**: Relaxed breathing (15 breaths/min, 60 bpm)
- **m2n7**: Deep sleep patterns (~14 breaths/min, 49 bpm)

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
| `sound_cond` | array | Sound condition labels | `["nan", "sync", "async", "isoc", "baseline"]` |
| `sound_codes` | array | Numerical event codes matching `sound_cond` order | `[0, 96, 160, 128, 192]` |

**Sound Conditions**:
- `nan`: No sound (spontaneous activity)
- `sync`: Sounds synchronized with respiratory phase
- `async`: Sounds presented asynchronously
- `isoc`: Isochronous rhythmic stimuli
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

% Access parameters
fs = config.fs;
sync_combos = config.sync_parameters.combinations;
output_path = config.output_dir;
```

#### Modifying Parameters Programmatically
```matlab
% Update configuration for different analysis
config.selected_cond = 'awake';
config.sync_parameters.T = 20;  % Increase minimum segment length

% Save modified configuration
json_str = jsonencode(config);
fid = fopen('config/config_awake.json', 'w');
fprintf(fid, '%s', json_str);
fclose(fid);
```

### Quick Configuration Examples

#### Testing New Synchronization Ratios
```json
"sync_parameters": {
  "combinations": ["m1n2", "m1n5", "m3n10"],
  "T": 12,
  "delta": 8
}
```

#### Processing Wake Data Only
```json
"selected_cond": "awake",
"data_path": "data/awake",
"sleep_stages": ["Awake"]
```

#### Strict Synchronization Criteria
```json
"sync_parameters": {
  "combinations": ["m1n3", "m1n4"],
  "T": 25,
  "delta": 3
}
```

### Configuration Best Practices

1. **Backup Before Editing**: Keep a copy of `config/config_default.json` with standard parameters
2. **Version Control**: Name configuration files descriptively (e.g., `config_pilot_study.json`, `config_main_analysis.json`)
3. **Validation**: Test new parameter sets on a single subject using `Extract_sync.m` before batch processing
4. **Documentation**: Add comments to your configuration files explaining non-standard choices
5. **Reproducibility**: Archive the exact configuration file used for each publication or report

### Troubleshooting

**Problem**: Script cannot find configuration file  
**Solution**: Ensure you're running MATLAB from the repository root directory, or use absolute paths in `config.json`

**Problem**: JSON parsing errors  
**Solution**: Validate JSON syntax at [jsonlint.com](https://jsonlint.com) before running scripts

**Problem**: Unrealistic synchronization results  
**Solution**: Verify `fs` matches your data's actual sampling rate, adjust `delta` threshold for stricter/looser detection

---

**Next Steps**: After configuring parameters, proceed to [Pipeline Workflow](#-pipeline-workflow) to begin analysis.

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



