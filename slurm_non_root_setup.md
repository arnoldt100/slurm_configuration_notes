# Configuring Slurm Daemons as Non-Root User on Ubuntu 24.04

This guide covers how to configure and run Slurm daemons (`slurmctld` and `slurmd`) entirely within user space without root or sudo privileges.

---

## Step 1: Create Custom Directories
Because non-root users cannot write to default system directories like `/etc/slurm` or `/var/log`, you must create local directories in your home folder for configuration files, state saves, process IDs (PIDs), and logs.

```bash
mkdir -p ~/slurm/etc
mkdir -p ~/slurm/spool/ctld
mkdir -p ~/slurm/spool/d
mkdir -p ~/slurm/log
mkdir -p ~/slurm/run
```

---

## Step 2: Configure slurm.conf for User-Space
Create a custom configuration file at `~/slurm/etc/slurm.conf`. This configuration overrides default file paths, targets non-privileged ports, and tells Slurm to use your current user account for execution.

Replace `$USER` with your actual Ubuntu username in the paths below if your environment does not auto-expand variables inside config files.

```ini
ClusterName=localcluster
SlurmctldHost=localhost

# Set execution to your non-root user
SlurmUser=$USER
SlurmdUser=$USER

# Custom State and Spool Paths
SlurmctldSpoolDir=/home/$USER/slurm/spool/ctld
SlurmdSpoolDir=/home/$USER/slurm/spool/d
SlurmctldLogFile=/home/$USER/slurm/log/slurmctld.log
SlurmdLogFile=/home/$USER/slurm/log/slurmd.log
SlurmdPidFile=/home/$USER/slurm/run/slurmd.pid
SlurmctldPidFile=/home/$USER/slurm/run/slurmctld.pid

# Port numbers (Non-privileged ports > 1024)
SlurmctldPort=6817
SlurmdPort=6818

# Single-Node Configuration (Adjust CPUs based on your system)
NodeName=localhost CPUs=4 State=UNKNOWN
PartitionName=debug Nodes=localhost Default=YES MaxTime=INFINITE State=UP
```

---

## Step 3: Run the Daemons

You can launch the daemons using one of two methods: via the terminal directly or through systemd user services.

### Option A: Running Manually in the Foreground
Launching in the foreground is highly recommended for initial testing so you can catch permission or configuration errors instantly.

1. **Start the Controller (`slurmctld`)**:
   ```bash
   slurmctld -D -f /home/$USER/slurm/etc/slurm.conf
   ```
2. **Start the Compute Daemon (`slurmd`)**:
   Open a separate terminal window or tab and run:
   ```bash
   slurmd -D -f /home/$USER/slurm/etc/slurm.conf
   ```

*Note: Remove the `-D` flag if you want to spawn them as background processes.*

### Option B: Running as User-Level Systemd Units
If you want Ubuntu to manage your daemons automatically without keeping active shell sessions open, use systemd user spaces.

1. **Create the Controller Service** (`~/.config/systemd/user/slurmctld.service`):
   ```ini
   [Unit]
   Description=Slurm controller daemon (User Space)
   After=network.target

   [Service]
   Type=simple
   ExecStart=%h/slurm/bin/slurmctld -D -f %h/slurm/etc/slurm.conf
   Restart=on-failure

   [Install]
   WantedBy=default.target
   ```
2. **Create the Compute Service** (`~/.config/systemd/user/slurmd.service`):
   ```ini
   [Unit]
   Description=Slurm compute daemon (User Space)
   After=network.target

   [Service]
   Type=simple
   ExecStart=%h/slurm/bin/slurmd -D -f %h/slurm/etc/slurm.conf
   Restart=on-failure

   [Install]
   WantedBy=default.target
   ```
3. **Enable and Start the Services**:
   ```bash
   systemctl --user daemon-reload
   systemctl --user enable --now slurmctld
   systemctl --user enable --now slurmd
   ```

---

## Step 4: Verify Your Setup
Confirm that the non-root cluster components are talking to each other and accepting command utilities by specifying your config path:

```bash
sinfo -f /home/$USER/slurm/etc/slurm.conf
squeue -f /home/$USER/slurm/etc/slurm.conf
```