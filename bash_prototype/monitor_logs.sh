#!/bin/bash

LOG_FILE="logs.log"
OUTPUT_FILE="log_report2.txt"
> "$OUTPUT_FILE"   #Truncate or create the report file

THRESHOLD_WARNING=300  # 5 minutes
THRESHOLD_ERROR=600    # 10 minutes

declare -A start_times
declare -A descriptions
declare -A seen_start
declare -A seen_end

line_number=0

while IFS=',' read -r timestamp description status pid; do
    line_number=$((line_number + 1))

    # Trim status (e.g., remove leading/trailing whitespace)
    status=$(echo "$status" | xargs)

    # Validate line has all 4 fields
    if [[ -z "$timestamp" || -z "$description" || -z "$status" || -z "$pid" ]]; then
        echo "MALFORMED: Line $line_number is missing fields and was skipped." >> "$OUTPUT_FILE"
        continue
    fi
     
     #!!! NOTE!!!: All timestamps are on the same day, 2024-01-01, so it`s a hardcoded dummy date (for now)
    epoch_time=$(date -d "2024-01-01 $timestamp" +%s 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "MALFORMED: Invalid timestamp at line $line_number: '$timestamp'" >> "$OUTPUT_FILE"
        continue
    fi

    key="$pid"

    if [[ "$status" == "START" ]]; then
        if [[ -n "${start_times[$key]}" ]]; then
            echo "DUPLICATE: START already recorded for PID $pid ($description) at line $line_number" >> "$OUTPUT_FILE"
            continue
        fi
        start_times["$key"]=$epoch_time
        descriptions["$key"]=$description
        seen_start["$key"]=1

    elif [[ "$status" == "END" ]]; then
        if [[ -n "${seen_end[$key]}" ]]; then
            echo "DUPLICATE: END already recorded for PID $pid ($description) at line $line_number" >> "$OUTPUT_FILE"
            continue
        fi
        start_time=${start_times["$key"]}
        if [[ -z "$start_time" ]]; then
            echo "UNMATCHED END: No START found for PID $pid ($description) at line $line_number" >> "$OUTPUT_FILE"
            continue
        fi

        duration=$((epoch_time - start_time))
        duration_str=$(printf '%02d:%02d:%02d' $((duration/3600)) $(( (duration%3600)/60 )) $((duration%60)))
        job_desc=${descriptions["$key"]}

     #generating alerts based on thresholds
        if (( duration > THRESHOLD_ERROR )); then
            echo "ERROR: Job '$job_desc' (PID: $pid) took $duration_str" >> "$OUTPUT_FILE"
        elif (( duration > THRESHOLD_WARNING )); then
            echo "WARNING: Job '$job_desc' (PID: $pid) took $duration_str" >> "$OUTPUT_FILE"
        else
            echo "INFO: Job '$job_desc' (PID: $pid) completed in $duration_str" >> "$OUTPUT_FILE"
        fi

        seen_end["$key"]=1
        unset start_times["$key"]
        unset descriptions["$key"]
    else
        echo "MALFORMED: Invalid status '$status' at line $line_number (expected START or END)" >> "$OUTPUT_FILE"
        continue
    fi

done < "$LOG_FILE"

# Report any jobs that never ended
for key in "${!start_times[@]}"; do
    echo "INCOMPLETE: Job '${descriptions[$key]}' (PID: $key) started but has no END." >> "$OUTPUT_FILE"
done
