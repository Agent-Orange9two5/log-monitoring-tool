import unittest
from io import StringIO
from pathlib import Path
import tempfile
import sys
import os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))     #allows to import the files from the parent directory
import monitor_logs

class TestLogMonitor(unittest.TestCase):

    def run_monitor_on_log(self, log_data: str) -> str:
        #create temp log file
        with tempfile.NamedTemporaryFile('w+', delete=False) as log_file:
            log_file.write(log_data)
            log_file.flush()
            log_path = Path(log_file.name)

            #output
            with tempfile.NamedTemporaryFile('w+', delete=False) as out_file:
                out_path = Path(out_file.name)

            #patch for testing
            monitor_logs.LOG_FILE = log_path
            monitor_logs.OUTPUT_FILE = out_path

            #main logic
            monitor_logs.process_log()

            #read output
            output = out_path.read_text()

        return output

    def test_valid_job_duration(self):
        log = """11:00:00,Test Job,START,11111
        11:06:30,Test Job,END,11111"""
        result = self.run_monitor_on_log(log)
        self.assertIn("WARNING: Job 'Test Job' (PID: 11111) took 0:06:30", result)

    def test_missing_start(self):
        log = "11:00:00,Orphan END,END,22222"
        result = self.run_monitor_on_log(log)
        self.assertIn("UNMATCHED END: No START found for PID 22222", result)

if __name__ == '__main__':
    unittest.main()
