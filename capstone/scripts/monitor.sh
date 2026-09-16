#!/bin/bash

LOG_FILE="$HOME/Desktop/devka14/capstone-satorixr/capstone/logs/alerts.log"

DISK_THRESHOLD=80
MEMORY_THRESHOLD=500
LOAD_THRESHOLD=4.0
PROCESS_THRESHOLD=300
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
ALERT_FOUND=0

DISK_USAGE=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')

MEMORY_AVAILABLE=$(vm_stat | awk '
/Pages free/ { free=$3 }
/Pages inactive/ { inactive=$3 }
/Pages speculative/ { speculative=$3 }
END {
    gsub("\\.","",free)
    gsub("\\.","",inactive)
    gsub("\\.","",speculative)
    print int((free + inactive + speculative) * 16384 / 1024 / 1024)
}')

LOAD_AVG=$(sysctl -n vm.loadavg | awk -F'[{} ,]+' '{print $2}')

if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
  echo "[$TIMESTAMP] ALERT: disk usage is at ${DISK_USAGE}%, threshold is ${DISK_THRESHOLD}%" >>"$LOG_FILE"
  ALERT_FOUND=1
fi

if [ "$MEMORY_AVAILABLE" -le "$MEMORY_THRESHOLD" ]; then
  echo "[$TIMESTAMP] ALERT: available memory is at ${MEMORY_AVAILABLE} MB, threshold is ${MEMORY_THRESHOLD} MB" >>"$LOG_FILE"
  ALERT_FOUND=1
fi

if awk "BEGIN {exit !($LOAD_AVG >= $LOAD_THRESHOLD)}"; then
  echo "[$TIMESTAMP] ALERT: load average is at ${LOAD_AVG}, threshold is ${LOAD_THRESHOLD}" >>"$LOG_FILE"
  ALERT_FOUND=1
fi

if [ "$ALERT_FOUND" -eq 0 ]; then
  echo "[$TIMESTAMP] OK: all metrics within thresholds" >>"$LOG_FILE"
fi
PROCESS_COUNT=$(ps -e | tail -n +2 | wc -l | tr -d ' ')

if [ "$PROCESS_COUNT" -ge "$PROCESS_THRESHOLD" ]; then
  echo "[$TIMESTAMP] ALERT: running processes are at ${PROCESS_COUNT}, threshold is ${PROCESS_THRESHOLD}" >>"$LOG_FILE"
  ALERT_FOUND=1
fi
