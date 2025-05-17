#  Log monitoring tool

This is a lightweight log monitoring utility that analyzes job execution durations from a structured log file. It alerts if jobs exceed certain thresholds.

The project began with a **Bash-based prototype** to demonstrate core parsing and monitoring logic with minimal dependencies. A more robust **Python implementation** was developed to support extensibility, structured logging, and service deployment.

The current project is fully functional and further improvements can be made in order to add more functionality.

---

## Project background

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

## Bash version capabilities

- Parse the log line by line
- Track job start and end by PID
- Calculate and report duration
- Detect jobs that run > 5 min (warning)
- Detect jobs that run > 10 min (error)
- Output results to log_report.txt 
- Handle job completion clean-up


## Python version capabilities

- All Bash version functionality, plus:
- Graceful handling of:
    - Malformed lines
    - Duplicate START or END
    - END without START
    - Jobs that never finished
- Time parsing with datetime
- Unit tests using unittest
- Temporary file simulation in tests
- Easily extensible structure
- Ready for packaging or service integration

---

## Running the scripts

In order to run the script, navigate to the bash_prototype and run the following command: 

  ```bash
./monitor_logs.sh
 ```
For the python version, navigate to the python_version folder, and run the command: 

  ```bash
python monitor_logs.py 
 ```
The unit tests are located under python_version/test/test_monitor.py, and you can run them using: 

  ```bash
python test_monitor.py
 ```
---

## Project structure

```bash
.
├── logs.log                     # Provided log file
├── log_report.txt              # Generated report (initial Bash output)
├── log_report2.txt             # Improved Bash output (for comparison/testing)
├── bash_prototype/
│   └── monitor_logs.sh         # Bash script
├── python_version/
│   ├── monitor_logs.py         # Python script
│   ├── log_report_py.txt       # Python-generated report
│   └── test/
│       ├── __init__.py         # Makes test folder importable
│       └── test_monitor.py     # Unit tests for Python version
└── README.md                   # Project documentation
```

---

## Potential enhancements

- Wrap the Bash script as a **systemd** service to run continuously in the background and monitor log files in real time (cron job)
- Add a CLI interface to the Python version using **argparse**, allowing users to specify log file paths and thresholds.
- Integrate alerting via Slack, email, or webhook in the Python version for real-time notifications when errors or warnings are detected
        
