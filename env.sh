#!/bin/bash

export PROXMOX_REMOTE_HOSTS="${PROXMOX_REMOTE_HOSTS:-localhost}"
export PROXMOX_USER="${PROXMOX_USER:-root}"
export PROXMOX_API_KEY="${PROXMOX_API_KEY:-}"
export ANSIBLE_HOST_KEY_CHECKING=False