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
		error_and_exit "You must specify 2 command line arguments for the SAP OS: an OS (RedHat or SLES), and the template name"
	fi
}
