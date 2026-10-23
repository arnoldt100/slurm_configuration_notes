#! /usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define Base Paths based on your installation layout
SLURM_BASE="${AT_SW_PACKAGES}/slurm-26.05.5"
MUNGE_BASE="${AT_SW_PACKAGES}/munge"

echo "===================================================="
echo "Creating Non-Root Slurm & MUNGE Directory Structure"
echo "===================================================="

# 1. Create MUNGE Directory Tree
echo "[+] Structuring MUNGE folders..."
mkdir -p "${MUNGE_BASE}/etc"
mkdir -p "${MUNGE_BASE}/var/run"
mkdir -p "${MUNGE_BASE}/var/log"

# 2. Create Slurm Directory Tree
echo "[+] Structuring Slurm folders..."
mkdir -p "${SLURM_BASE}/etc"
mkdir -p "${SLURM_BASE}/var/slurmctld"   # State save location
mkdir -p "${SLURM_BASE}/var/slurmd"      # Slurmd spool directory
mkdir -p "${SLURM_BASE}/var/run"         # PID files
mkdir -p "${SLURM_BASE}/var/log"         # Log files

# 3. Enforce Strict Non-Root Security Permissions
echo "[+] Enforcing user-space security permissions..."

# Restrict entire var folders to ONLY your user account
chmod 700 "${MUNGE_BASE}/var/run"
chmod 700 "${MUNGE_BASE}/var/log"
chmod 700 "${SLURM_BASE}/var/slurmctld"
chmod 700 "${SLURM_BASE}/var/slurmd"
chmod 700 "${SLURM_BASE}/var/run"
chmod 700 "${SLURM_BASE}/var/log"

# 4. Generate MUNGE Security Cryptographic Key if missing
if [ ! -f "${MUNGE_BASE}/etc/munge.key" ]; then
    echo "[+] Generating a secure local 1024-byte MUNGE secret key..."
    dd if=/dev/urandom bs=1 count=1024 of="${MUNGE_BASE}/etc/munge.key" 2>/dev/null
    chmod 400 "${MUNGE_BASE}/etc/munge.key"
else
    echo "[!] MUNGE key already exists at ${MUNGE_BASE}/etc/munge.key. Skipping generation."
fi

# 5. Enforce the correct file permissions for a securely configured MUNGE
echo "Ensure all directories in the MUNGE path to 700"
find ${MUNGE_BASE} -type d -exec chmod 700 {} +

echo "Ensure the critical key remains strictly read-only"
chmod 400 ${MUNGE_BASE}/etc/munge.key

echo "----------------------------------------------------"
echo "Setup Successful!"
echo "Directories are structured and locked down."

