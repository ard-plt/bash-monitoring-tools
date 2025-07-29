# Bash Monitoring Tools

A collection of simple and practical Bash scripts for monitoring system performance on Linux systems.

## Tools Included

### 1. `cpu_monitor.sh`
Monitors average CPU usage per core over a specified time period.

-  Calculates usage by reading `/proc/stat`
-  Default duration: 300 seconds
-  Sampling interval: 10 seconds
-  Outputs average CPU usage for each core

### 2. `network_monitor.sh`
Monitors per-interface network activity over a given time window.

-  Default duration: 300 seconds
-  Measures received/sent bytes and packet counts
-  Calculates average packet size


