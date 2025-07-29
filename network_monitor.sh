#!/bin/bash

TIME=300
INTERFACES=($(ls /sys/class/net | grep -v lo))

declare -A RX_START TX_START RX_PKTS_START TX_PKTS_START
declare -A RX_SUM TX_SUM RX_PKTS_SUM TX_PKTS_SUM

for IFACE in "${INTERFACES[@]}"; do
    RX_START[$IFACE]=$(< /sys/class/net/$IFACE/statistics/rx_bytes)
    TX_START[$IFACE]=$(< /sys/class/net/$IFACE/statistics/tx_bytes)
    RX_PKTS_START[$IFACE]=$(< /sys/class/net/$IFACE/statistics/rx_packets)
    TX_PKTS_START[$IFACE]=$(< /sys/class/net/$IFACE/statistics/tx_packets)
done

sleep "$TIME"

for IFACE in "${INTERFACES[@]}"; do
    RX_END=$(< /sys/class/net/$IFACE/statistics/rx_bytes)
    TX_END=$(< /sys/class/net/$IFACE/statistics/tx_bytes)
    RX_PKTS_END=$(< /sys/class/net/$IFACE/statistics/rx_packets)
    TX_PKTS_END=$(< /sys/class/net/$IFACE/statistics/tx_packets)

    RX_SUM[$IFACE]=$((RX_END - RX_START[$IFACE]))
    TX_SUM[$IFACE]=$((TX_END - TX_START[$IFACE]))
    RX_PKTS_SUM[$IFACE]=$((RX_PKTS_END - RX_PKTS_START[$IFACE]))
    TX_PKTS_SUM[$IFACE]=$((TX_PKTS_END - TX_PKTS_START[$IFACE]))
done

echo ""
echo "Network Activity Over ${TIME}s:"
for IFACE in "${INTERFACES[@]}"; do
    RX_BYTES=${RX_SUM[$IFACE]}
    TX_BYTES=${TX_SUM[$IFACE]}
    RX_PKTS=${RX_PKTS_SUM[$IFACE]}
    TX_PKTS=${TX_PKTS_SUM[$IFACE]}

    RX_AVG=$((RX_PKTS > 0 ? RX_BYTES / RX_PKTS : 0))
    TX_AVG=$((TX_PKTS > 0 ? TX_BYTES / TX_PKTS : 0))

    echo ""
    echo "INTERFACE: $IFACE"
    echo "  RX Packets : $RX_PKTS | Total Received : $RX_BYTES bytes | Avg Packet Size: $RX_AVG bytes"
    echo "  TX Packets : $TX_PKTS | Total Sent     : $TX_BYTES bytes | Avg Packet Size: $TX_AVG bytes"
done
