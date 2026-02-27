# Macroeconomic Filters & The Business Cycle

This repository contains the **Stata** and **R** code used in the video: [**The Mathematical Illusion Fooling Economists**](https://youtu.be/gNVQQp7GMEo). 

It provides the tools to replicate the full spectral analysis, cyclical extraction, and periodograms shown in the video. Whether you are looking to run a simple HP filter or want to prove mathematically why the Hamilton filter collapses into a 2-year growth rate, everything you need is here.

## 📂 Repository Contents

To make this repository accessible, the code is split into a "Master" file that replicates the entire video, and "Simplified" modules if you only want to learn or apply one specific filter.

| File Name | R Script | Stata Script | Description |
| :--- | :---: | :---: | :--- |
| **Full Analysis** |
| `Filters_All` | `[R]` | `[.do]` | The master script. Generates all trend, cycle, and periodogram figures shown in the video. |
| **Simplified Modules** |
| `Filters_HP` | `[R]` | `[.do]` | Extracts the trend/cycle using the Hodrick-Prescott filter. |
| `Filters_Hamilton` | `[R]` | `[.do]` | Extracts the cycle using the Hamilton regression filter. |
| `Filters_GrowthRates` | `[R]` | `[.do]` | Calculates QoQ and YoY growth rates and their spectral densities. |
| **Data Files** |
| `CDataQ.csv` | - | - | Quarterly macroeconomic data (Real GDP, etc.). |
| `CDataM.csv` | - | - | Monthly macroeconomic data (Employment, etc.). |

## The Data
The datasets provided (`CDataQ.csv` and `CDataM.csv`) contain the raw Canadian macroeconomic data used for the demonstrations. 

*Note: These datasets are covered in my comprehensive Canadian data guide. If you want to pull your own updated data, visit the [statscan-econ-data-guide repository](https://github.com/SSEconomics/statscan-econ-data-guide).*

## 🚀 How to Use This Code

### For R Users:
1. Clone or download the repository.
2. Open your preferred R IDE (e.g., RStudio).
3. Ensure you have the required packages installed (the scripts will list dependencies at the top, such as `mFilter`, `ggplot2`, or `dplyr`).
4. Run the `Filters_All.R` script to generate all figures, or explore the modular scripts.

### For Stata Users:
1. Clone or download the repository.
2. Open Stata and change your working directory (`cd`) to the folder containing the `.do` and `.csv` files.
3. Run `do Filters_All.do` to replicate the video analysis.

## Key Takeaways from the Code
Running `Filters_All` will empirically demonstrate the core arguments from the video:
* **The Time Machine:** How the HP filter forces the trend down *before* a crash.
* **The Hamilton Collapse:** How the estimated Hamilton filter OLS coefficients place almost all weight on the first lag, mathematically turning the complex regression into a linearly detrended 2-year growth rate.
* **The Noise Multiplier:** How standard Quarter-over-Quarter growth rates act as high-pass filters, amplifying high-frequency noise and destroying the business cycle frequencies.

## Let's Connect
If you found this code helpful, or if you managed to break it and find something new, let me know in the comments of the YouTube video. 

* **YouTube:** [Stephen Snudden](https://www.youtube.com/@SSEconomics)
* **GitHub:** [@SSEconomics](https://github.com/SSEconomics)
