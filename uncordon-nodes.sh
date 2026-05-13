#!/bin/bash
set -euo pipefail

# it is expected that the oc command is in your path and your session has the 
# required KUBECONFIG environment vars set
#
# "oc whoami" should return something like system:admin or something of equivalent access

state_file="${POWER_CYCLE_STATE_FILE:-./cordoned-nodes.txt}"

if [[ ! -s "${state_file}" ]]; then
  echo "No cordoned node state found at ${state_file}; refusing to uncordon every node." >&2
  echo "Set POWER_CYCLE_STATE_FILE if the state file is elsewhere." >&2
  exit 1
fi

while IFS= read -r openshift_node
do
  [[ -n "${openshift_node}" ]] || continue
  oc adm uncordon "${openshift_node}"
done < "${state_file}"

rm -f "${state_file}"
