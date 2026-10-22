# Slurm Non-Root Environment Setup Guide

When running **Slurm** daemons (`slurmctld` and `slurmd`) inside a custom user space without root privileges, setting up proper environment variables is critical. It allows Slurm client commands (`sbatch`, `srun`, `sinfo`, `squeue`) to communicate seamlessly with your custom controller setup.

---

## 1. Core Slurm Environment Variables

| Variable | Purpose | Recommended Value |
| :--- | :--- | :--- |
| **`SLURM_CONF`** | Points client commands directly to your custom config file instead of `/etc/slurm/slurm.conf`. | `"$HOME/slurm/etc/slurm.conf"` |
| **`SLURM_PID_DIR`** | Designates the runtime path for Slurm daemon PID tracking files. | `"$HOME/slurm/var/run"` |
| **`SLURM_LOCALID`** | Used internally by plugins and scripts to track node tasks. | Automatically set during execution |

---

## 2. Automating Your Environment (Persistent Configuration)

To avoid declaring these paths every time you open a new shell, append them to your shell's initialization script (e.g., `~/.bashrc` or `~/.zshrc`).

### Step-by-Step Configuration

1. **Open your configuration file:**
   ```bash
   nano ~/.bashrc
   ```

2. **Append the following configuration block at the bottom of the file:**
   ```bash
   # Custom Slurm User-Space Environment
   export SLURM_CONF="$HOME/slurm/etc/slurm.conf"
   
   # Add Slurm custom binaries and user space paths to system paths
   if [ -d "$HOME/slurm/bin" ]; then
       export PATH="$HOME/slurm/bin:$PATH"
       export PATH="$HOME/slurm/sbin:$PATH"
   fi
   ```

3. **Apply the changes immediately:**
   ```bash
   source ~/.bashrc
   ```

---

## 3. Verifying the Custom Setup

Once your environment is refreshed, ensure your clients point to your custom user directory instead of system locations by running these quick tests.

* **Check the variable registration:**
  ```bash
  echo $SLURM_CONF
  ```
  *(Should print your custom home folder directory path)*

* **Verify command location routing:**
  ```bash
  which sinfo
  ```
  *(Should output a path starting with `$HOME/slurm/bin/sinfo`)*

* **Query the running custom controller:**
  ```bash
  sinfo
  ```
