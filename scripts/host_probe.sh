#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/netpulse_probe.log"
TARGET_URL="http://127.0.0.1"
DEFAULT_GW=$(ip route show default | awk '{print $3}')
OPEN_PORTS=$(ss -H -tuln | wc -l)
DNS_MS=$(dig google.com | awk '/Query time/ {printf "%.1fms",$4}')
HTTP_RAW=$(curl -s -o /dev/null -m 3 -w "%{http_code} %{time_total}\n" "$TARGET_URL" || echo "000 0") 
read -r HTTP_CODE HTTP_LATENCY <<< "$HTTP_RAW"


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
METRICS_MSG="load=$LOAD_AVG ram=$RAM_USAGE disk=$DISK_USAGE gw=$DEFAULT_GW ports=$OPEN_PORTS dns=$DNS_MS http=$HTTP_CODE latency=${HTTP_LATENCY}s"
log_msg "INFO" "$METRICS_MSG"
