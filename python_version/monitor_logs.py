#!/usr/bin/env python3
import csv
from datetime import datetime, timedelta
from pathlib import Path

#config
LOG_FILE = Path("../logs.log")
OUTPUT_FILE = Path("log_report_py.txt")
DATE_FORMAT = "%H:%M:%S"
FAKE_DATE = "2024-01-01"

#thresholds calculated
THRESHOLD_WARNING = 5 * 60
THRESHOLD_ERROR = 10 * 60

#state
start_times = {}
descriptions = {}
seen_start = set()
seen_end = set()

#function to convert time string to epoch seconds
def time_to_epoch(ts: str) -> int:
    try:
        dt = datetime.strptime(f"{FAKE_DATE} {ts.strip()}", f"%Y-%m-%d {DATE_FORMAT}")
        return int(dt.timestamp())
    except ValueError:
        return None


def process_log():
    with LOG_FILE.open("r", encoding="utf-8") as f, OUTPUT_FILE.open("w", encoding="utf-8") as out:
        reader = csv.reader(f)
        for line_number, row in enumerate(reader, 1):
            if len(row) != 4:
                out.write(f"MALFORMED: Line {line_number} is missing fields and was skipped.\n")
                continue

            timestamp, description, status, pid = [col.strip() for col in row]
            status = status.upper()

            epoch_time = time_to_epoch(timestamp)
            if epoch_time is None:
                out.write(f"MALFORMED: Invalid timestamp at line {line_number}: '{timestamp}'\n")
                continue

            key = pid

            if status == "START":
                if key in start_times:
                    out.write(f"DUPLICATE: START already recorded for PID {pid} ({description}) at line {line_number}\n")
                    continue
                start_times[key] = epoch_time
                descriptions[key] = description
                seen_start.add(key)

            elif status == "END":
                if key in seen_end:
                    out.write(f"DUPLICATE: END already recorded for PID {pid} ({description}) at line {line_number}\n")
                    continue
                if key not in start_times:
                    out.write(f"UNMATCHED END: No START found for PID {pid} ({description}) at line {line_number}\n")
                    continue

                duration = epoch_time - start_times[key]
                duration_str = str(timedelta(seconds=duration))
                job_desc = descriptions.get(key, "Unknown")

                if duration > THRESHOLD_ERROR:
                    out.write(f"ERROR: Job '{job_desc}' (PID: {pid}) took {duration_str}\n")
                elif duration > THRESHOLD_WARNING:
                    out.write(f"WARNING: Job '{job_desc}' (PID: {pid}) took {duration_str}\n")
                else:
                    out.write(f"INFO: Job '{job_desc}' (PID: {pid}) completed in {duration_str}\n")

                seen_end.add(key)
                del start_times[key]
                del descriptions[key]

            else:
                out.write(f"MALFORMED: Invalid status '{status}' at line {line_number} (expected START or END)\n")
                continue

        #checks and logging for jobs that never ended
        for pid, start_time in start_times.items():
            job_desc = descriptions.get(pid, "Unknown")
            out.write(f"INCOMPLETE: Job '{job_desc}' (PID: {pid}) started but has no END.\n")

if __name__ == "__main__":
    process_log()
