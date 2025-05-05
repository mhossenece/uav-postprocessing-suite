# UAV Post-Processing Suite

📡 **UAV-Assisted Wireless Data Collection Analysis Toolkit**  
Author: [Md Sharif Hossen](https://github.com/mhossenece)  
PhD Student, Electrical and Computer Engineering, NCSU  
Advisors: Dr. Ismail Guvenc and Dr. Vijay K. Shah  
Date: May 4, 2025

---

## ✨ Overview

This MATLAB-based post-processing suite provides a full pipeline to evaluate the performance of UAV-assisted wireless data collection missions. It converts raw log files into structured datasets, computes key performance metrics, and visualizes mission results, enabling in-depth analysis of throughput, fairness, and coverage in multi-base-station scenarios.

---

## ⚙️ Workflow Summary

1. **Convert** raw telemetry (`controller_log.txt`, `vehicleOut.txt`) to CSV  
2. **Merge** SNR and download data with UAV GPS logs  
3. **Compute** data volumes, cumulative download, and final mission score  
4. **Visualize**:
   - UAV trajectory + geofence + eNodeBs
   - Download progress vs. time
   - Remaining data per base station
   - Final score breakdown

---

## 📁 File Structure

| Script                     | Description                                                                 |
|---------------------------|-----------------------------------------------------------------------------|
| `main.m`                  | Master script that executes the full pipeline                              |
| `txt_to_csv_vehicle_snr.m`| Parses `vehicleOut.txt` and `controller_log.txt` to CSV (SNR & GPS)         |
| `txt_to_csv_download.m`   | Parses download values from `controller_log.txt`                            |
| `csv_merge.m`             | Merges telemetry and download/SNR CSV files                                 |
| `volume.m`                | Extracts total data volumes per base station                                |
| `score.m`                 | Extracts mission time, scores, and final score                              |
| `extract_last_download.m`| Extracts final download snapshot for each base station                      |
| `plot_geofence_trajectory.m`| Plots UAV trajectory, geofence, and eNodeBs                             |
| `uav_cumulative_download_plot.m`| Plots cumulative downloads with distance overlay                 |
| `volume_bar_plot.m`       | Bar chart of initial assigned data volumes                                  |
| `plot_remaining_data.m`   | Bar chart of remaining data per base station                                |
| `plot_uav_score.m`        | Visualizes final S1, S2, and combined score                                  |

---

## 📦 Inputs

- `controller_log.txt`  
- `vehicleOut.txt`  
- `AERPAW_UAV_Geofence_Phase_1.kml`

> Ensure these files are in the working directory before running `main.m`.

---

## 📊 Outputs

Figures are saved in the `/figs` directory:
- `trajectory.png` — UAV path with geofence and base stations
- `cumulative_download_vs_time.png` — Download + distance over time
- `data_volume_per_base_station.png` — Initial data volume chart
- `remaining_data_barplot.png` — Data left uncollected
- `uav_download_metrics.png` — Score breakdown

---

## 📚 Citation

If you use this suite in your research, please cite:

