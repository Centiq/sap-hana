# System Design and Deployment

## Contents

- [System Design and Deployment](#system-design-and-deployment)
  - [Contents](#contents)
  - [Overview](#overview)
  - [Phase 1: Installation Media and Configuration File Acquisition Process](#phase-1-installation-media-and-configuration-file-acquisition-process)
    - [Phase 1 Prerequisites](#phase-1-prerequisites)
    - [Phase 1 Inputs](#phase-1-inputs)
    - [Phase 1 Process](#phase-1-process)
    - [Phase 1 Output](#phase-1-output)
  - [Phase 2: Installation Media Preparation and Configuration File Preparation](#phase-2-installation-media-preparation-and-configuration-file-preparation)
    - [Phase 2 Prerequisites](#phase-2-prerequisites)
    - [Phase 2 Inputs](#phase-2-inputs)
    - [Phase 2 Process](#phase-2-process)
    - [Phase 2 Examples](#phase-2-examples)
    - [Phase 2 Outputs](#phase-2-outputs)
  - [Phase 3: Installation of SAP System on Target VMs](#phase-3-installation-of-sap-system-on-target-vms)
    - [Phase 3 Prerequisites](#phase-3-prerequisites)
    - [Phase 3 Inputs](#phase-3-inputs)
    - [Phase 3 Process](#phase-3-process)
    - [Phase 3 Outputs](#phase-3-outputs)

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

### Phase 1 Prerequisites

- User must have an SAP account which has the correct permissions to download software and access Maintenance Planner

### Phase 1 Inputs

- SAP account login details (username, password)
- SAP System Product to deploy e.g. `S/4HANA`
- SAP Database configuration
- System name (SID)
- OS intended for use on HANA Infrastructure
- Language pack requirements

### Phase 1 Process

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

### Phase 1 Output

- XML Stack file
- SAP Installation Media
- Stack Download Directory path containing Installation Media

## Phase 2: Installation Media Preparation and Configuration File Preparation

### Phase 2 Prerequisites

- Acquisition process complete

### Phase 2 Inputs

- SAP XML Stack file stored on user’s workstation in the Stack Download Directory.
- SAP Media stored on user’s workstation in the Stack Download Directory.
- SAP Library to be prepared with the SAP Media.

### Phase 2 Process

1. Upload SAP Media from workstation to SAP Library. This process will create a repository of archive files, tools and Stack files to be used with deploying systems. See [Examples 1.](https://github.com/Centiq/sap-hana/blob/centiq-automation-process-high-level/documentation/ansible/system-design-deployment.md#2---examples) for file structure.
1. Upload the downloaded media and stack files to the sapbits container in the Storage Account for the SAP Library, using the directory structure shown in [Examples 1.](https://github.com/Centiq/sap-hana/blob/centiq-automation-process-high-level/documentation/ansible/system-design-deployment.md#2---examples).
1. Open the SAP Library Storage Account in the Azure portal and navigate into the sapbits container.
1. Click into archives.
1. Click any file.
1. Copy the URL property and make note, the top level domain will be used later in the process, e.g. (<https://npeus2saplibef9d.blob.core.windows.net>).
1. Create SAP Unattended Installation Template(s) (process TBD in Milestone 2).
1. Upload into SAP Library.
1. Click Upload.
1. In the panel on the right, click Select a file.
1. Navigate your workstation to your download directory.
1. Select all unattended installation template files (*.j2).
1. Click Advanced to show the advanced options, and enter “templates” for the Upload Directory.
1. Create the BoM file and upload it into SAP Library.
1. Populate BoM with required inputs show in [Examples 2.](https://github.com/Centiq/sap-hana/blob/centiq-automation-process-high-level/documentation/ansible/system-design-deployment.md#2---examples)
1. Upload BoM files to SAP Library.
1. Click Upload.
1. In the panel on the right, click Select a file.
1. Navigate your workstation to your Stack Download directory.
1. Select all bom files (bom.yaml).
1. Click Advanced to show the advanced options, and enter “BoMs” for the Upload Directory.
1. Define SAP Library path Storage account in Ansible either in the Ansible inventory or passed into a playbook as a parameter i.e sap_lib_root_url: `https://<storage_acount_name>.blob.core.windows.net/<container_name>/`. The same applies to the file destination on the target vm as all media will be extracted to one directory.

### Phase 2 Examples

1. Example file structure:

   ```text
   sapbits
   |
   |-- archives/
   |   |-- igshelper_17-1001245.sar
   |   |-- KE60870.SAR
   |   |-- KE60871.SAR
   |   |-- <id>[.SAR|.sar]
   |   |-- SAPCAR_1320-80000935.EXE
   |   |-- <tool>_<id>.EXE
   |
   |-- BoMs/
   |   |-- S4HANA_1909_v1/
   |   |   |-- bom.yml
   |   |   |-- stackfiles/
   |   |   |   |-- MP_Excel_1001034051_20200921_SWC.xls
   |   |   |   |-- MP_Plan_1001034051_20200921_.pdf
   |   |   |   |-- MP_Stack_1001034051_20200921_.txt
   |   |   |   |-- MP_Stack_1001034051_20200921_.xml
   |   |   |   |-- templates/
   |   |   |       |-- hana.ini
   |   |   |       |-- application.ini
   |   |-- BW4HANA_1909_v1/
   |   |   |-- ...
   |   |-- BW4HANA_1909_v2/
   |   |   |-- ...
   ```

   **Note:** This process will create a repository of archive files, tools and Stack files to be used with deploying systems.

   **Note:** All Installation Media tools and files for all systems designed by the user will be contained within a single flat directory to avoid duplication.

   **Note:** The Bill of Materials directory (BoMs/) will contain a folder for each system the user designs.  The recommended naming convention for these folders will use the product type(e.g. S4HANA), product version (e.g. 1909), and a version marker (e.g. v1). This allows the user to update a particular system BoM and retain an earlier version should it ever be needed.

   **Note:** The Bill of Materials file (bom.yml) and template files (hana.ini, application.ini) will be created following manual steps described later in this process.

   **Note:** Additional SAP files obtained from SAP Maintenance Planner (the XML Stack file, Text file representation of stack file, the PDF and xls files) will be stored in a subfolder.

   **Note:** Stack files are made unique by an index, e.g. `MP_<type>_<index>_<date>_<???>.<filetype>` where `<type>` is Stack, Plan, or Excel, `<index>` is a 10 digit integer, `<date>` is in format yyyymmdd, `<???>` is SWC for the Excel type and empty for the rest, and `<filetype>` is xls for type Excel, pdf for type Plan, and txt or xml for type Stack.

1. Example BoM file:

   ```yaml
   ### BOM ###
   ---
   #
   # BOM    :  S/4 - 1909
   # Version:  001
   # Name   :  BoM_S41909v1

   #
   # Target :  ABAP PLATFORM 1909              01    (02/2020)
   #

   #
   # Product ID's
   #
   ProductIdSCS: NW_ABAP_ASCS:S4HANA1909.CORE.HDB.ABAP

   # Installation Template
   installation_template_path: 'sapbits/stack_files/templates/application.ini'

   # Stack_file
   stack_file_path: 'sapbits/bom/s4hana_1909_v1/stack_file/MP_Stack_1001034051_20200921.xml'

   # BASE INSTALL

   # billOfMaterials:
   # -
   #   fileName:       ''          (Required: Target filename after download; Full path)
   #   permissions:    ''          (Optional: File permissions in octal;         Default: 0644)
   #   creates:        ''          (Optional: Filename to indicate if extract was performed)
   #   include:        ''          (Optional: Install additional components via additional BoM file)

   billOfMaterials:

   # Depencies
   -   path: BoMs/S4HANA_1909_v1/bom.yml
       Include: true

   # SAPCAR 7.21
   -   filename: 'SAPCAR_****_********.EXE'
       permissions: '{{ sap_permission }}'

   # SWPM 2.0
   -   fileName:       'SWPM20SP05_5-80003424.SAR'
       creates:        'SIGNATURE.SMF'
       permissions: '{{ sap_permission }}'

   # ABAP_ASCS
   -   fileName:       'S4CORE101.SAR.SAR'
       creates:        'SIGNATURE.SMF'
   ```

   **Note:** The configuration for each individual HANA component will be stored in "Sub BoMs" in order to allow for independent installs when required.

### Phase 2 Outputs

- SAP Media has been stored in SAP Library
- Consolidated SAP Unattended Install Template has been stored in SAP Library
- BoM has been stored in SAP Library
- SAP Library file path defined in Ansible inventory or passed in as a perameter to a playbook.

## Phase 3: Installation of SAP System on Target VMs

### Phase 3 Prerequisites

- Bootstrap infrastructure has been deployed
- Bootstrap infrastructure has been configured
  - Deployer has been configured with working Ansible
  - SAP Library contains all media for the relevant BoM
- SAP infrastructure has been deployed
  - SAP Library contains all Terraform state files for the environment
  - Deployer has Ansible connectivity to SAP Infrastructure (e.g. SSH keys in place/available via key vault)
  - Ansible inventory has been created

### Phase 3 Inputs

- BoM (contents and format TBD)
- Ansible inventory that details deployed SAP Infrastructure
  - Note: Inventory contents and format TBD, but may contain reference to the SAP Library
- SID (likely to exist in Ansible inventory in some form)
- Unattended install template

### Phase 3 Process

1. Run Ansible playbook on SCS VM to configure base-level OS
1. Run Ansible playbook on SCS VM to configure OS groups and users
   1. Use defaulted gids/uids
1. Run Ansible playbook on SCS VM to configure SAP OS prerequisites
   1. Ensures software dependencies are installed (e.g. those found in SAP notes such as 2361652). For example:
      1. `uuidd`
      1. `nfs-utils`
      1. `nmap-ncat`
      1. `resource-agents-sap`
   1. Configures dependencies (e.g. those found in SAP notes such as #2600030). For example:
      1. `selinux/apparmor` (permissive)
      1. `uuid` (started)
      1. `/etc/sysctl.d/sap.conf` (populated)
      1. `sysctl` (reloaded)
      1. `/etc/security/limits.d/99-sap.conf` (populated)
      1. `/var/sapAutomation/lock` (exists)
1. Run Ansible playbook on SCS VM to configure LVM
   1. Ensures correct volumes are created
1. Run Ansible playbook on SCS VM to configure SAP mounts
   1. Ensures correct directory structure exists
      1. `/sapmnt`
      1. `/usr/sap`
      1. `/usr/sap/trans`
      1. `/usr/sap/<SID>`
      1. `/usr/sap/<SID>/ASCS<ascs_inst_no>`
      1. `/usr/sap/<SID>/ERS<ers_inst_no>`
      1. `/usr/sap/<SID>/SYS`
   1. Ensures file systems are mounted
      1. `/etc/fstab`
1. Run Ansible playbook on SCS VM to configure NFS and create/export media directory
   1. Ensures correct directory structure exists
      1. `/sapmnt/<SID>`
      1. `/usr/sap/install`
   1. Ensures media folders are exported
1. Run Ansible playbook on SCS VM to unarchive SAP Media and extract to exported media directory
   1. Iterates over BoM content to:
      1. Ensure media extracted (sapcar) to correct location(s)
      1. Ensure unattended install templates are extracted to correct location
      1. Ensure ini files are extracted to correct location
1. Run Ansible playbook on SCS VM to deploy SAP product components (swpm)

### Phase 3 Outputs

- SAP product has been deployed and running - ready to handle SAP client requests
- Connection details/credentials so the Basis Admin can configure any SAP clients
