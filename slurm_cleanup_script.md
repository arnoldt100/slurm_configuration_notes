# Automated Slurm Cleanup Script\n\nSave the code block below as `stop_slurm.sh`, grant it executable permissions, and run it whenever you need to clean up your user-space cluster.\n\n```bash\n#!/bin/bash
# ==============================================================================
# Slurm Non-Root Process Cleanup Script
# ==============================================================================
# This script gracefully terminates slurmctld and slurmd instances owned by the
# current non-root user. If they do not exit gracefully, it escalates to SIGKILL.

# Text styling
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo -e "${BOLD}Starting Slurm Non-Root Process Cleanup...${RESET}\n"

# 1. Try stopping via systemd user space first
if systemctl --user is-active --quiet slurmctld 2>/dev/null || systemctl --user is-active --quiet slurmd 2>/dev/null; then
    echo -e "${YELLOW}[Systemd]${RESET} Found active Slurm user services. Attempting graceful stop..."
    systemctl --user stop slurmctld slurmd 2>/dev/null
    sleep 2
fi

# 2. Find any remaining manual process PIDs
PIDS=$(ps -u $USER -o pid,comm | grep -E 'slurmctld|slurmd' | awk '{print $1}')

if [ -z "$PIDS" ]; then
    echo -e "${GREEN}[Success]${RESET} No active Slurm processes found for user ${BOLD}$USER${RESET}."
    exit 0
fi

echo -e "${YELLOW}[Manual]${RESET} Found running Slurm processes with PIDs: $(echo $PIDS | tr '\n' ' ')"

# 3. Send SIGTERM (Graceful shutdown)
echo "Sending SIGTERM to processes..."
kill -SIGTERM $PIDS 2>/dev/null

# Wait up to 5 seconds for processes to clear
for i in {1..5}; do
    PIDS=$(ps -u $USER -o pid,comm | grep -E 'slurmctld|slurmd' | awk '{print $1}')
    if [ -z "$PIDS" ]; then
        echo -e "${GREEN}[Success]${RESET} All Slurm processes terminated gracefully."
        exit 0
    fi
    sleep 1
done

# 4. Escalate to SIGKILL if processes are still stuck
echo -e "${RED}[Warning]${RESET} Processes refused to exit gracefully. Sending SIGKILL..."
kill -9 $PIDS 2>/dev/null
sleep 1

# Final verification
PIDS=$(ps -u $USER -o pid,comm | grep -E 'slurmctld|slurmd' | awk '{print $1}')
if [ -z "$PIDS" ]; then
    echo -e "${GREEN}[Success]${RESET} Forced cleanup complete. No remaining Slurm processes."
else
    echo -e "${RED}[Error]${RESET} Failed to kill processes: $(echo $PIDS | tr '\n' ' ')"
    exit 1
fi
```\n\n### How to Use the Script\n| Action | Command |\n| :--- | :--- |\n| **1. Create the file** | `nano stop_slurm.sh` *(Paste the code above into it)* |\n| **2. Make it executable** | `chmod +x stop_slurm.sh` |\n| **3. Execute the script** | `./stop_slurm.sh` |\n