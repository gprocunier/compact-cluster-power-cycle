#!/bin/bash
set -euo pipefail

# it is expected that the oc command is in your path and your session has the 
# required KUBECONFIG environment vars set
#
# it is also required that the public key used to provision the cluster is available to the
# ssh client so it can log in as core

# "oc whoami" should return something like system:admin or something of equivalent access

# loop over the nodes and get their ip addresses
declare -A shutdown_pids=()

for openshift_node in $(oc get nodes -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}')
do
  # log into the node via ssh as the core user  and start a shutdown +2 gives all the nodes a chance to shutdown together
  # we fork an attempt for each server so this happens all at once
  ssh -o BatchMode=yes -o ConnectTimeout=10 "core@${openshift_node}" 'sudo shutdown -h +2' &
  shutdown_pids["$!"]="${openshift_node}"
done

failed=0

for pid in "${!shutdown_pids[@]}"; do
  if ! wait "${pid}"; then
    echo "Shutdown command failed for ${shutdown_pids[$pid]}" >&2
    failed=1
  fi
done

exit "${failed}"
