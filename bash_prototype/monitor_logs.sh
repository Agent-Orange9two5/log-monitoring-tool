#!/bin/bash

#I/O files
LOG_FILE="logs.log"
OUTPUT_FILE="log_report.txt"
> "$OUTPUT_FILE"         #Truncate or create the report file

THRESHOLD_WARNING=300  #5 min
THRESHOLD_ERROR=600    #10 min

declare -A start_times
declare -A descriptions

while IFS=',' read -r timestamp description status pid; do
    status=$(echo "$status" | xargs)  #trim whitespace

    #Convert time to epoch for easy duration calculation
    #!!! NOTE!!!: All timestamps are on the same day, 2024-01-01, so it`s a hardcoded dummy date (for now)
    epoch_time=$(date -d "2024-01-01 $timestamp" +%s) || continue
    key="$pid"

    if [[ "$status" == "START" ]]; then
        start_times["$key"]=$epoch_time
        descriptions["$key"]=$description
    elif [[ "$status" == "END" ]]; then
        start_time=${start_times["$key"]}
        if [[ -z "$start_time" ]]; then
            echo "WARN: No START found for PID $pid ($description)" >> "$OUTPUT_FILE"  #If there is no corresponding START found, logs a warning and skips
            continue
        fi

        duration=$((epoch_time - start_time))
        duration_str=$(printf '%02d:%02d:%02d' $((duration/3600)) $(( (duration%3600)/60 )) $((duration%60)))
        job_desc=${descriptions["$key"]}

        #Generating alerts based on thresholds

        if (( duration > THRESHOLD_ERROR )); then
            echo "ERROR: Job '$job_desc' (PID: $pid) took $duration_str" >> "$OUTPUT_FILE"
        elif (( duration > THRESHOLD_WARNING )); then
            echo "WARNING: Job '$job_desc' (PID: $pid) took $duration_str" >> "$OUTPUT_FILE"
        else
            echo "INFO: Job '$job_desc' (PID: $pid) completed in $duration_str" >> "$OUTPUT_FILE"
        fi

        unset start_times["$key"]
        unset descriptions["$key"]
    fi
done < "$LOG_FILE"