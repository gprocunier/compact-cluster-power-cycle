* Gather quick cluster intelligence before changing state.
* Take an etcd backup before shutting down the cluster.
* Cordon all OpenShift nodes so no new workloads are scheduled while the cluster is being prepared for maintenance.
* Do not drain the nodes for this procedure. Since this is a full cluster shutdown, workload eviction does not add value here.
* Schedule all OpenShift hosts to shut down together. The shutdown script should SSH to each node as core and issue a delayed shutdown, so all nodes begin the shutdown process at roughly the same time.
* When starting the cluster again, power on all nodes together.
* After the API is available again, uncordon the nodes that were cordoned for this maintenance window.
