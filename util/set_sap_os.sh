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
	local target_json="${target_template_dir}/${json_template_name}.json"
	local temp_template_json="${target_json}.tmp"


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

	# We need the jq "walk" method from v1.6 - build it by hand if jq is pre-1.6
	local jq_version=$(jq --version | cut -f2 -d-)
	if [[ ${jq_version} == "1.6" ]]; then
		jq_def_walk=""
	else
	  jq_def_walk="def walk(f): . as \$in | if type == \"object\" then reduce keys_unsorted[] as \$key ( {}; . + { (\$key): (\$in[\$key] | walk(f)) } ) | f elif type == \"array\" then map( walk(f) ) | f else f end;"
  fi

	# Always set new values, regardless of any values already present
	jq "${jq_def_walk}walk(if type == \"array\" then map(.os?.publisher=\"${sap_os_publisher}\") else . end)" ${target_json} >${temp_template_json} && mv ${temp_template_json} ${target_json}
	jq "${jq_def_walk}walk(if type == \"array\" then map(.os?.offer=\"${sap_os_offer}\") else . end)" ${target_json} >${temp_template_json} && mv ${temp_template_json} ${target_json}
	jq "${jq_def_walk}walk(if type == \"array\" then map(.os?.sku=\"${sap_os_sku}\") else . end)" ${target_json} >${temp_template_json} && mv ${temp_template_json} ${target_json}
}

# Execute the main program flow with all arguments
main "$@"
