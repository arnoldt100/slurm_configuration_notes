#!/bin/bash

module load slurm/26.05.05

start_cluster() {
    echo "=========================================="
    echo "Spinning Up User-Space Slurm Cluster Engine"
    echo "=========================================="

    # 1. Start MUNGE Daemon (Must always launch first)
    if pgrep -u "$USER" x_munged > /dev/null || pgrep -u "$USER" munged > /dev/null; then
        echo "[!] MUNGE daemon is already running."
    else
        echo "[+] Starting munged..."
        munged --socket="$MUNGE_SOCKET" \
               --pid-file="$MUNGE_DIR/var/run/munged.pid" \
               --log-file="$MUNGE_DIR/var/log/munged.log" \
               --key-file="$MUNGE_DIR/etc/munge.key"
	       --seed-dir="${MUNGE_DIR}/var/lib" \
               --state-dir="${MUNGE_DIR}/var/lib" 
               
        # Give it a brief instant to establish its socket interface
        sleep 1
    fi

    # Verify MUNGE is functionally answering requests
    if munge -n | unmunge > /dev/null 2>&1; then
        echo "[✓] MUNGE authentication test: PASSED"
    else
        echo "[X] MUNGE authentication test: FAILED. Check logs at $MUNGE_DIR/var/log/munged.log"
        exit 1
    fi

    # 2. Start Slurm Controller (slurmctld)
    if pgrep -u "$USER" slurmctld > /dev/null; then
        echo "[!] slurmctld is already running."
    else
        echo "[+] Starting slurmctld..."
        slurmctld
    fi

    # 3. Start Slurm Node Daemon (slurmd)
    if pgrep -u "$USER" slurmd > /dev/null; then
        echo "[!] slurmd is already running."
    else
        echo "[+] Starting slurmd..."
        slurmd
    fi

    echo "------------------------------------------"
    echo "[✓] Core services initiated. Checking cluster state..."
    sleep 2
    sinfo
}

stop_cluster() {
    echo "=========================================="
    echo "Shutting Down User-Space Slurm Cluster Engine"
    echo "=========================================="

    echo "[-] Terminating slurmd..."
    if [ -f "$SLURM_DIR/var/run/slurmd.pid" ]; then
        kill $(cat "$SLURM_DIR/var/run/slurmd.pid") 2>/dev/null || true
    else
        pkill -u "$USER" slurmd || true
    fi

    echo "[-] Terminating slurmctld..."
    if [ -f "$SLURM_DIR/var/run/slurmctld.pid" ]; then
        kill $(cat "$SLURM_DIR/var/run/slurmctld.pid") 2>/dev/null || true
    else
        pkill -u "$USER" slurmctld || true
    fi

    echo "[-] Terminating munged..."
    if [ -f "$MUNGE_DIR/var/run/munged.pid" ]; then
        kill $(cat "$MUNGE_DIR/var/run/munged.pid") 2>/dev/null || true
    else
        pkill -u "$USER" munged || true
    fi

    echo "------------------------------------------"
    echo "[✓] All user-space cluster daemons stopped."
}

status_cluster() {
    echo "=========================================="
    echo "Cluster Service Operational Status Summary"
    echo "=========================================="
    printf "%-15s %-10s %-10s\n" "DAEMON" "STATUS" "PID"
    printf "%-15s %-10s %-10s\n" "------" "------" "---"
    
    for daemon in munged slurmctld slurmd; do
        pid=$(pgrep -u "$USER" -x "$daemon" | head -n 1)
        if [ -n "$pid" ]; then
            printf "%-15s \e[32m%-10s\e[0m %-10s\n" "$daemon" "RUNNING" "$pid"
        else
            printf "%-15s \e[31m%-10s\e[0m %-10s\n" "$daemon" "STOPPED" "-"
        fi
    done
}

case "$1" in
    start)
        start_cluster
        ;;
    stop)
        stop_cluster
        ;;
    restart)
        stop_cluster
        sleep 2
        start_cluster
        ;;
    status)
        status_cluster
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac

