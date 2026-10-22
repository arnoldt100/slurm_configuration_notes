#! /usr/bin/env bash

declare -r installation_dir="${AT_SW_PACKAGES}/slurm-26.05.5"

# sudo apt update && sudo apt install libmariadb-dev
# sudo apt install libnuma-dev
# sudo apt install libpam0g-dev
# sudo apt install -y libjson-c-dev
# sudo apt install libjwt-dev
# sudo apt install libhttp-parser-dev
# sudo apt install -y git build-essential npm
# sudo apt install libyaml-dev
# sudo apt install liblz4-dev lz4
# sudo apt install -y build-essential pkg-config autoconf
# sudo apt install libhwloc-dev
# sudo apt install libmunge-dev
#
# sudo add-apt-repository multiverse
# sudo apt update
# sudo apt install libnvidia-ml-dev
#
# sudo apt install librdkafka-dev
# sudo apt install -y libgtk2.0-dev pkg-config
# sudo apt install man2html
#
# Ignored configure warnings:
#
# configure: WARNING: unable to locate ofed installation
# ofed is only needed if one has an InfiniBand hardware
#
# "configure: WARNING: unable to locate libze_loader.so
# and/or ze_api.h"
# Not using Intel GPUs
#
# configure: WARNING: support for pmix is disabled by default
# pmix is for large HPC clusters. My machine is a single node.
#
# configure: WARNING: unable to locate freeipmi installation (libipmonitoring/libfreeipmi
# Not planning to use Slurm's energy accounting or IPMI node
# power management.
#
# configure: WARNING: unable to locate 1.5.7+ s2n library
#
# configure: WARNING: unable to build with BPF token support, BPF token support will be disabled. kernel-headers version >= 6.9
#
# configure: WARNING: HPE Slingshot: unable to locate libcxi/libcxi.h

./configure --prefix=${installation_dir} \
  --without-ofed \
  --without-pmix \
  --without-freeipmi \
  --without-s2n \
  --without-bpf

# make

# make tests

# make install
