#!/bin/bash
#SBATCH --job-name=workstation_test   # Name of the job
#SBATCH --partition=workstation       # Target your custom partition
#SBATCH --nodes=1                     # Run on a single node
#SBATCH --ntasks=4                    # Launch 4 MPI processes (half your logical CPUs)
#SBATCH --cpus-per-task=2             # Allocate 2 threads per process (4 tasks x 2 = 8 logical CPUs)
#SBATCH --gres=gpu:1                  # Request your NVIDIA T1000 GPU
#SBATCH --time=00:05:00               # 5-minute time limit
#SBATCH --output=cluster_test_%j.log  # Standard output file (%j expands to JobID)
#SBATCH --error=cluster_test_%j.err   # Standard error file

echo "=========================================================="
echo "      Slurm Non-Root Workstation Execution Benchmark       "
echo "=========================================================="
echo "Job Started at: $(date)"
echo "Running on Node: $SLURM_NODELIST"
echo "Allocated CPU Cores: $SLURM_NTASKS"
echo "Allocated GPU GRES: $SLURM_JOB_GPUS"
echo "----------------------------------------------------------"

# 1. Environment Verification
echo "[+] Verifying active environment variables..."
echo "SLURM_CONF: $SLURM_CONF"
echo "MUNGE_SOCKET: $MUNGE_SOCKET"

# 2. Test GPU Availability within the Slurm Allocation
echo -e "\n[+] Testing NVIDIA T1000 Hardware Visibility:"
nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader

# 3. Test Open MPI Pipeline Execution
echo -e "\n[+] Executing Open MPI Pipeline (4 Parallel Tasks):"
# Note: In user-space installations, standard 'mpirun' or 'mpiexec' handles execution natively.
mpirun -np $SLURM_NTASKS hostname | sort

echo -e "\n=========================================================="
echo "Job Finished at: $(date)"
echo "=========================================================="

