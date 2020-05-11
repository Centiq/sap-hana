# Testing the Cluster Guide for v2

This document describes the process for performing some basic, automated cluster tests.

The following 'Test the Cluster Setup' tests have been automated for [SLES](https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/sap-hana-high-availability#test-the-cluster-setup) and [RHEL](https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/sap-hana-high-availability-rhel#test-the-cluster-setup) deployments:

1. Test the migration
1. Test the Azure fencing agent
1. Test the failover

The tests are run from the Runtime Instance (RTI). For each of these tests, the failover condition will be triggered against the Master node, and the process will pause. You will be asked to monitor the process on the Slave node, which should be done from a second terminal session connected via the RTI.

Once the described state is achieved on the Slave node cluster monitoring, you can resume the process by pressing Enter. The process will then attempt to re-establish a healthy cluster, and pause until you see confirmation on the Slave node.

## Prerequisites

For connecting to the RTI, you will need the username (default: `azureadm`) and IP address of the RTI which are output at the end of the Terraform.

If this isn't immediately available, the Username and Public IP address can be found from the Terraform State file:

```text
$ grep -A60 -m1 '"name": "rti"' terraform.tfstate | grep -E \(\"public_ip_address\"\|\"admin_username\"\)
            "admin_username": "azureadm",
            "public_ip_address": "xxx.xxx.xxx.xxx",
```

Alternatively, if the Username is known, the Public IP can be found through the Azure Portal.

You will also need the logon username and Private IP addresses for the HANA DB Nodes.

### Connecting to the Runtime Instance VM

It is recommended for the tests that you have two terminal sessions.

The first will be used to issue the commands and give confirmation of state changes after time. The second will be used to monitor the cluster status.

Connect to the RTI: `ssh <username>@<public_ip_address>`

### Running a Failover Test

A helper script for running a Cluster test has been provided, `~/sap-hana/deploy/v2/test_cluster.sh`

To see the available cluster tests, run the script with no arguments:

```text
$ ~/sap-hana/deploy/v2/test_cluster.sh
You must specify a single command line argument for the failover test type. Valid types:
  - migrate      - Test migration of Master node
  - fence_agent  - Test the Fencing Agent by making the network interface unavailable
  - service      - Test failover by stopping the cluster service
```

To run a test, add the test type as the only argument to the script:

```text
$ ~/sap-hana/deploy/v2/test_cluster.sh migrate
```

This will check if the deployment is in a suitable state for testing by checking that:

1. The OS clustering has been configured.
1. The HANA System Replication has been configured and is in a healthy state.

The next steps the process reports will be about information it has gathered from the Cluster configuration for the process, and then it will trigger the test type.

At this point it will output instructions telling you which node to monitor from, and the command to use:

```text
TASK [test-failover : Inform user of how and where to monitor failover progress] **********************************************************************
ok: [10.1.1.4] => {
    "msg": "To monitor failover progress, on hdb1-0 as root run 'crm_mon -r'"
}
skipping: [10.1.1.5]
```

In your seconnd SSH terminal session, connect via SSH to the node requested, then escalate to to root: `sudo -i`

Run the command provided:

- SLES: `crm_mon -r`
- RHEL: `watch -n 10 pcs status --full`

Monitor the failover until the information displayed for the Master/Slave set meets the output provided:

```text
TASK [test-failover : Wait for user confirmation of desired state] *******************************************************************
[test-failover : Wait for user confirmation of desired state]
Failover migration test in progress, approx 3 minutes. Expect to see 'Masters: [ hdb1-0 ]' and 'Stopped: [ hdb1-1 ]'. Press Enter to reestablish the cluster, or CTRL+C to abort
```

Once the desired state has been reached, press Enter and the process will attempt to re-establish a healthy cluster. This process can take from 1-5 minutes, so will ask you to monitor for the desired state again:

```text
TASK [test-failover : Wait for user confirmation of desired state] *******************************************************************
[test-failover : Wait for user confirmation of desired state]
Expect to see 'Masters: [ hdb1-0 ]' and 'Slaves: [ hdb1-1 ]':
```
