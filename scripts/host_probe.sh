#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/netpulse_probe.log"






LOAD_AVG=$(awk '{print $1}' /proc/loadavg)
RAM_USAGE=$(free -m | awk '/Mem:/ {printf "%0.1f%%",($3*100)/$2}' )
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}')

timestamp(){
    date "+%Y-%m-%d %H:%M:%S"
}


log_msg(){

    local LEVEL="$1"
    local message="$2"
    echo "[$(timestamp)] [$LEVEL] $message" | tee -a "$LOG_FILE"
}
host_metrics="load=$LOAD_AVG ram=$RAM_USAGE disk=$DISK_USAGE"
log_msg "INFO" "$host_metrics"
