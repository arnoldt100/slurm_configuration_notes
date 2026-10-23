-- -*- lua -*-
-- Modulefile for User-Space Slurm & MUNGE environment setup
-- Tailored for Slurm 26.05.5 on Ubuntu

help([[
This module adds the custom user-space Slurm and MUNGE installations to your path.
It configures the environment to look for local configuration directories and sockets.
]])

whatis("Name: Slurm")
whatis("Version: 26.05.5")
whatis("Description: Slurm Workload Manager and MUNGE Authentication (User-Space)")

-- Define Base Installation Paths
local slurm_dir = "${AT_SW_PACKAGES}/slurm-26.05.5"
local munge_dir = "${AT_SW_PACKAGES}/munge"

-- Update System Paths for Executables and Libraries
prepend_path("PATH",            slurm_dir .. "/bin")
prepend_path("PATH",            slurm_dir .. "/sbin")
prepend_path("PATH",            munge_dir .. "/bin")
prepend_path("PATH",            munge_dir .. "/sbin")

prepend_path("LD_LIBRARY_PATH", slurm_dir .. "/lib")
prepend_path("LD_LIBRARY_PATH", munge_dir .. "/lib")
prepend_path("MANPATH",         slurm_dir .. "/share/man")
prepend_path("MANPATH",         munge_dir .. "/share/man")

-- Environment Variables for Slurm Configurations
setenv("SLURM_CONF",            slurm_dir .. "/etc/slurm.conf")

-- Directs Slurm/MUNGE client commands to your user-space socket position
setenv("MUNGE_SOCKET",          munge_dir .. "/var/run/munge.local.s")

