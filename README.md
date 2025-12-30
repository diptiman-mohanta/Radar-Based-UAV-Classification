A sophisticated radar-based object classification system that distinguishes between UAVs (drones), birds, RC aircraft, and mixed scenarios using advanced signal processing techniques and deep learning.
# Features
Advanced Signal Processing: Implementation of Successive Variational Mode Decomposition (SVMD) for superior signal analysis

Cross-term-free Spectrograms: Enhanced time-frequency representations for better classification accuracy

Transfer Learning: Utilizes pre-trained SqueezeNet for efficient feature extraction

Multi-class Classification: Distinguishes between drones, birds, RC planes, and mixed scenarios

Automated Pipeline: End-to-end processing from raw radar data to classification result

# Methodology
![image](https://github.com/user-attachments/assets/106a473c-a4f2-404a-be82-c4ca6b9ba9ce)

Signal Processing Pipeline

Preprocessing: Downsampling, resampling, and low-pass filtering

SVMD Decomposition: Successive decomposition into Intrinsic Mode Functions (IMFs)

Spectrogram Generation: Cross-term-free STFT computation

Feature Extraction: Deep CNN features using SqueezeNet

Classification: Multi-class object identification

# Key Algorithms

SVMD (Successive Variational Mode Decomposition): Advanced signal decomposition technique

VMD (Variational Mode Decomposition): Standard mode decomposition for comparison

Transfer Learning: Pre-trained CNN feature extraction

# Prerequisites

MATLAB R2020b or later (using 2023b) 

Signal Processing Toolbox

Deep Learning Toolbox

Image Processing Toolbox

## Installation

```bash
git clone https://github.com/diptiman-mohanta/Radar-Based-UAV-Classification.git
cd Radar-Based-UAV-Classification
```


# Citation

If you use this work in your research, please cite:

```bibtex
@misc{radar_uav_classification,
  title={Radar-Based UAV Classification using SVMD, Spectogram and Deep Learning},
  author={Diptiman Mohanta and Akash S R and Shekh Sharfraj and Krishna Jyoti Panda and Arpita Pradhan and Jyotirmayee Patnaik},
  year={2025},
  url={https://github.com/diptiman-mohanta/Radar-Based-UAV-Classification.git}
}
```
# Dataset

```bibtex
@data{1x2q-8v62-22,
doi = {10.21227/1x2q-8v62},
url = {https://dx.doi.org/10.21227/1x2q-8v62},
author = {Harish Chandra Kumawat and Mainak Chakraborty and A. Arockia Bazil Raj and Sunita Vikrant Dhavale},
publisher = {IEEE Dataport},
title = {DIAT-µSAT: micro-Doppler Signature Dataset of Small Unmanned Aerial Vehicle (SUAV)},
year = {2022} }
```

to use the dataset i have used mail to the authors to provide the .mat files you can get the email id in this [https://ieee-dataport.org/documents/diat-msat-micro-doppler-signature-dataset-small-unmanned-aerial-vehicle-suav]
