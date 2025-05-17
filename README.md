#  Log Monitoring Tool

This is a lightweight log monitoring utility that analyzes job execution durations from a structured log file. It alerts if jobs exceed certain thresholds.

The project began with a **Bash-based prototype** to demonstrate core parsing and monitoring logic with minimal dependencies. A more robust **Python implementation** is being developed to support extensibility, structured logging, and service deployment.

---

## Project Background

As part of a DevOps coding challenge, the goal was to:
- Parse a CSV-style log file
- Track job execution start/end times by PID
- Calculate and report duration
- Alert:
  - Warning if > 5 minutes
  - Error if > 10 minutes

---

##  Technologies

| Language | Purpose |
|----------|---------|
| Bash     | Rapid prototyping, system scripting |
| Python   | Production-level parsing, testability, future integration as service |

---

## Project Structure

```bash
.
├── logs.log                # Provided log file
├── log_report.txt          # Generated report (initial report format - no improvement) 
├── log_report2.txt         # Generated report 2 (improved version - old version available for comparison)
├── bash_prototype/
│   └── monitor_logs.sh     # Bash script
├── python_version/        
│   ├── monitor_logs.py          # Python script
│   ├── log_report_py.txt        # Python report
│   └── tests/
└── README.md               
