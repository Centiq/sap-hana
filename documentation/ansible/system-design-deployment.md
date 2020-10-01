# System Design and Deployment

## Contents

1. [Overview](#overview)
1. [Phase 1: Installation Media and Configuration File Acquisition Process](#phase-1-installation-media-and-configuration-file-acquisition-process)

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

### Prerequisites

- User must have an SAP account which has the correct permissions to download software and access Maintenance Planner

### Inputs

- SAP account login details (username, password)
- SAP System Product to deploy e.g. `S/4HANA`
- SAP Database configuration
- System name (SID)
- OS intended for use on HANA Infrastructure
- Language pack requirements

### Process

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

### Output

- XML Stack file
- SAP Installation Media
- Stack Download Directory path containing Installation Media
