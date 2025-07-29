#!/bin/bash

DURATION=300      
INTERVAL=10      
COUNT=$((DURATION / INTERVAL))  


CORES=($(grep "^cpu[0-9]" /proc/stat | awk '{print $1}'))


declare -A PREV_IDLE
declare -A PREV_TOTAL


declare -A SUM_ACTIVE
declare -A SUM_TOTAL


read_cpu_stats() {
    grep "^cpu[0-9]" /proc/stat | while read -r cpu user nice system idle iowait irq softirq steal guest guest_nice; do
        total=$((user + nice + system + idle + iowait + irq + softirq + steal))
        echo "$cpu $idle $total"
    done
}

while read -r cpu idle total; do
    PREV_IDLE["$cpu"]=$idle
    PREV_TOTAL["$cpu"]=$total
    SUM_ACTIVE["$cpu"]=0
    SUM_TOTAL["$cpu"]=0
done < <(read_cpu_stats)

START_TIME=$(date +%s)

for ((i = 0; i < COUNT; i++)); do
    TARGET_TIME=$((START_TIME + i * INTERVAL))
    NOW=$(date +%s)
    SLEEP_TIME=$((TARGET_TIME - NOW))
    ((SLEEP_TIME > 0)) && sleep "$SLEEP_TIME"

    while read -r cpu idle total; do
        prev_idle=${PREV_IDLE["$cpu"]}
        prev_total=${PREV_TOTAL["$cpu"]}

        diff_idle=$((idle - prev_idle))
        diff_total=$((total - prev_total))
        diff_active=$((diff_total - diff_idle))

        SUM_ACTIVE["$cpu"]=$((SUM_ACTIVE["$cpu"] + diff_active))
        SUM_TOTAL["$cpu"]=$((SUM_TOTAL["$cpu"] + diff_total))

        PREV_IDLE["$cpu"]=$idle
        PREV_TOTAL["$cpu"]=$total
    done < <(read_cpu_stats)
done

echo "CPU Kullanım Ortalamaları (Son ${DURATION} saniye):"
for cpu in "${CORES[@]}"; do
    active=${SUM_ACTIVE["$cpu"]}
    total=${SUM_TOTAL["$cpu"]}

    if (( total > 0 )); then
        usage=$((100 * active / total))
    else
        usage=0
    fi

    printf "%-5s: %3d%%\n" "$cpu" "$usage"
done
