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

## 🧠 Developed for AADM Challenge

This framework was developed as part of the **AERPAW Autonomous Data Mule (AADM) Challenge #2**, a UAV competition organized by the **AERPAW platform**. The objective is to design UAV algorithms that dynamically optimize trajectory and base station selection to maximize throughput and minimize latency under real-time constraints.

Learn more about the AADM Challenge here:  
👉 [AERPAW AADM Student Challenge](https://aerpaw.org/aerpaw-aadm-challenge/)

---

## 🙏 Acknowledgments

This project was supported as part of my participation in the **AERPAW Autonomous UAV Student Challenge #2 – AADM (Autonomous Data Mule) Challenge**.  
Special thanks to the AERPAW team and the broader testbed and digital twin community at North Carolina State University for providing the infrastructure, data, and opportunity for experimental UAV research.

---



## 📚 Citation

If you use this suite in your research, please cite:
Md Sharif Hossen. UAV Post-Processing Suite.
Available at: https://github.com/mhossenece/uav-postprocessing-suite

---

### 📌 BibTeX Citation

```bibtex
@misc{hossen2025uavpost,
  author       = {Md Sharif Hossen},
  title        = {{UAV Post-Processing Suite: MATLAB Toolkit for Analyzing UAV-Assisted Wireless Data Collection Missions}},
  year         = {2025},
  howpublished = {\url{https://github.com/mhossenece/uav-postprocessing-suite}},
  note         = {Version 1.0. Accessed: 2025-05-04}
}

🛠 Requirements
MATLAB R2020b or later
Mapping Toolbox (for geofence KML parsing)
Log files: controller_log.txt, vehicleOut.txt


🤝 Contributions
Pull requests and forks for academic collaboration are welcome.

---

## ✅ 2. `LICENSE` (Academic Use Only Template)

MIT License (Academic Use Only Variant)

Copyright (c) 2025 Md Sharif Hossen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to use,
copy, modify, merge, and publish the Software for **academic and non-commercial
research purposes only**, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

Commercial use, sublicensing, or redistribution of the Software or its
derivatives is not permitted without explicit prior written permission from
the author.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

