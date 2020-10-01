# System Design and Deployment

## Contents

1. [Overview](#overview)
1. [Phase 1: Installation Media and Configuration File Acquisition Process](#phase-1-installation-media-and-configuration-file-acquisition-process)
   1. [Prerequisites](#1---prerequisites)
   1. [Inputs](#1---inputs)
   1. [Process](#1---process)
   1. [Outputs](#1---outputs)
1. [Phase 2: Installation Media Preparation and Configuration File Preparation](#phase-2-installation-media-preparation-and-configuration-file-preparation)
   1. [Prerequisites](#2---prerequisites)
   1. [Inputs](#2---inputs)
   1. [Process](#2---process)
   1. [Outputs](#2---outputs)
1. [Phase 3: Installation of SAP System on Target VMs](#phase-3-installation-of-sap-system-on-target-vms)
   1. [Prerequisites](#3---prerequisites)
   1. [Inputs](#3---inputs)
   1. [Process](#3---process)
   1. [Outputs](#3---outputs)

## Overview

This document will contain high-level instructions for designing a SAP System, obtaining the installation media and configuration files, generating files required for an automated deployment, and installing the SAP system.

At the current time, the document is aimed at users with experience with deploying SAP systems, and with familiarty and access to tools like SAP Launchpad, Maintenance Planner, and Download Manager.  Users are also expected to have familiarity with Azure deployments and the Azure Portal.

This process happens in 3 phases, with Azure Infrastruture Provisioning following a separate process:

1. Installation Media and Configuration File Acquisition
   - This phase can does not depend on any Azure resources, and can happen before or after the provisioning of the SAP Azure Infrastructure.
1. Installation Media Preparation and Configuration File Preparation
   - This and the following phase can only happen once the SAP Azure Infrastructure has been deployed.
1. Installation of SAP System on Target VMs

## Phase 1: Installation Media and Configuration File Acquisition Process

### 1 - Prerequisites

- User must have an SAP account which has the correct permissions to download software and access Maintenance Planner

### 1 - Inputs

- SAP account login details (username, password)
- SAP System Product to deploy e.g. `S/4HANA`
- SAP Database configuration
- System name (SID)
- OS intended for use on HANA Infrastructure
- Language pack requirements

### 1 - Process

_**Note:** The Preparation and Deployment stages will be independent of each other in the sense that the preparation stage can happen at any time before the user wishes to begin the Deployment stage, however the Deployment cannot happen without Preparation being completed._

1. Create unique Stack Download Directory for SAP Downloads on User Workstation, e.g. `~/Downloads/S4HANA_Stack_SID/`
1. Log in to [SAP Launchpad](https://launchpad.support.sap.com/#)
1. Navigate to Software Downloads to clear the download basket
1. Find the SAP HANA Database media (Database and any additional components required) and add to download basket
1. Log in to [Maintenance Planner](https://support.sap.com/en/alm/solution-manager/processes-72/maintenance-planner.html)
1. Design System, e.g. `S/4HANA`
1. Download Stack XML file to Stack Download Directory
1. Click `Push to Download Basket`
1. Download additional files (Stack Text File, PDF, Excel export)
1. Download and install the [SAP Download Manager](https://softwaredownloads.sap.com/file/0030000001316872019)
1. Log into SAP Download Basket within SAP Download Manager
1. Set download directory to Stack Download Directory created at beginning of Phase 1
1. Download all files into empty DIR on workstation

### 1 - Output

- XML Stack file
- SAP Installation Media
- Stack Download Directory path containing Installation Media

## Phase 2: Installation Media Preparation and Configuration File Preparation

### 2 - Prerequisites

### 2 - Inputs

### 2 - Process

### 2 - Outputs

## Phase 3: Installation of SAP System on Target VMs

### 3 - Prerequisites

1. Bootstrap infrastructure has been deployed
1. Bootstrap infrastructure has been configured
   1. Deployer has been configured with working Ansible
   1. SAP Library contains all media for the relevant BoM
1. SAP infrastructure has been deployed
   1. SAP Library contains all Terraform state files for the environment
   1. Deployer has Ansible connectivity to SAP Infrastructure (e.g. SSH keys in place/available via key vault)
   1. Ansible inventory has been created

### 3 - Inputs

1. BoM (contents and format TBD)
1. Ansible inventory that details deployed SAP Infrastructure
   1. Note: Inventory contents and format TBD, but may contain reference to the SAP Library
1. SID (likely to exist in Ansible inventory in some form)
1. Unattended install template

### 3 - Process

1. Run Ansible playbook on SCS VM to configure base-level OS
1. Run Ansible playbook on SCS VM to configure OS groups and users
   1. Use defaulted gids/uids
1. Run Ansible playbook on SCS VM to configure SAP OS prerequisites
   1. Ensures software dependencies are installed (e.g. those found in SAP notes such as 2361652 )
      1. `uuidd`
      1. `nfs-utils`
      1. `nmap-ncat`
      1. `resource-agents-sap`
      1. ... etc
   1. Configures dependencies (e.g. those found in SAP notes such as #2600030)
      1. `selinux/apparmor` (permissive)
      1. `uuid` (started)
      1. `/etc/sysctl.d/sap.conf` (populated)
      1. `sysctl` (reloaded)
      1. `/etc/security/limits.d/99-sap.conf` (populated)
      1. `/var/sapAutomation/lock` (exists)
      1. ... etc
1. Run Ansible playbook on SCS VM to configure LVM
   1. Ensures correct volumes are created
1. Run Ansible playbook on SCS VM to configure SAP mounts
   1. Ensures correct directory structure exists
      1. `/sapmnt`
      1. `/usr/sap`
      1. `/usr/sap/trans`
      1. `/usr/sap/&lt;SID>`
      1. `/usr/sap/&lt;SID>/ASCS&lt;ascs_inst_no>`
      1. `/usr/sap/&lt;SID>/ERS&lt;ers_inst_no>`
      1. `/usr/sap/&lt;SID>/SYS`
   1. Ensures file systems are mounted
      1. `/etc/fstab`
1. Run Ansible playbook on SCS VM to configure NFS and create/export media directory
   1. Ensures correct directory structure exists
      1. `/sapmnt/&lt;SID>`
      1. `/usr/sap/install`
   1. Ensures media folders are exported
1. Run Ansible playbook on SCS VM to unarchive SAP Media and extract to exported media directory
   1. Iterates over BoM content to:
      1. Ensure media extracted (sapcar) to correct location(s)
      1. Ensure unattended install templates are extracted to correct location
      1. Ensure ini files are extracted to correct location
1. Run Ansible playbook on SCS VM to deploy SAP product components (swpm)

### 3 - Outputs

1. SAP product has been deployed and running - ready to handle SAP client requests
1. Connection details/credentials so the Basis Admin can configure any SAP clients
