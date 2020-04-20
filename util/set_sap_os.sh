#!/usr/bin/env bash

###############################################################################
#
# Purpose:
# This script simplifies the user interaction with the JSON input templates so
# the user does not need to manually edit JSON files when configuring the
# required OS for their SAP HANA VMs.
#
###############################################################################

# exit immediately if a command fails
set -o errexit

# exit immediately if an unset variable is used
set -o nounset

# import common functions that are reused across scripts
source util/common_utils.sh


function main()
{
	check_command_line_arguments "$@"

	local sap_os="$1"
	local template_name="$2"

	edit_json_template_for_sap_os "${sap_os}" "${template_name}"
}


function check_command_line_arguments()
{
	local args_count=$#

	# Check there are just two arguments provided
	if [[ ${args_count} -ne 2 ]]; then
		echo "Available Templates:"
		list_available_templates
		error_and_exit "You must specify 2 command line arguments: the SAP OS (RedHat or SLES), and the template name"
	fi
}


function list_available_templates()
{
	print_allowed_json_template_names "${target_template_dir}" | grep 'hana'
}


function edit_json_template_for_sap_os()
{
	local sap_os="$1"
	local json_template_name="$2"

  local sap_os_publisher
  local sap_os_offer
  local sap_os_sku

  if [[ ${sap_os,,} == 'sles' ]]; then
    sap_os_publisher="suse"
    sap_os_offer="sles-sap-12-sp5"
    sap_os_sku="gen1"
  elif [[ ${sap_os,,} == 'redhat' ]]; then
    sap_os_publisher="RedHat"
    sap_os_offer="RHEL-SAP-HA"
    sap_os_sku="76sapha-gen2"
  else
		echo "Available SAP OS values:"
		echo "  SLES"
    echo "  RedHat"
		error_and_exit "You must specify one of the above values (case not significant) and the template name as parameters"
  fi

	# these are the JSON path in jq format
	local sap_os_publisher_json_path='"databases", "os", "publisher"'
	local sap_os_offer_json_path='"databases", "os", "offer"'
	local sap_os_sku_json_path='"databases", "os", "sku"'

	# Always set, regardless of any values already present
  edit_json_template_for_path "${sap_os_publisher_json_path}" "${sap_os_publisher}" "${json_template_name}"
  edit_json_template_for_path "${sap_os_offer_json_path}" "${sap_os_offer}" "${json_template_name}"
  edit_json_template_for_path "${sap_os_sku_json_path}" "${sap_os_sku}" "${json_template_name}"
}


# Execute the main program flow with all arguments
main "$@"
