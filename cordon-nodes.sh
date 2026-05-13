#!/bin/bash
set -euo pipefail

# it is expected that the oc command is in your path and your session has the 
# required KUBECONFIG environment vars set
#
# "oc whoami" should return something like system:admin or something of equivalent access

state_file="${POWER_CYCLE_STATE_FILE:-./cordoned-nodes.txt}"

if [[ -s "${state_file}" ]]; then
  echo "Refusing to overwrite non-empty state file: ${state_file}" >&2
  echo "Run uncordon-nodes.sh first, move the file aside, or set POWER_CYCLE_STATE_FILE to a different path." >&2
  exit 1
fi

: > "${state_file}"

while IFS=$'\t' read -r openshift_node unschedulable
do
  [[ -n "${openshift_node}" ]] || continue

  if [[ "${unschedulable}" == "true" ]]; then
    echo "Skipping already cordoned node: ${openshift_node}"
    continue
  fi

  oc adm cordon "${openshift_node}"
  printf '%s\n' "${openshift_node}" >> "${state_file}"
done < <(oc get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.unschedulable}{"\n"}{end}')
