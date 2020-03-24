#!/usr/bin/env bash

###############################################################################
#
# Purpose:
# This script simplifies the user interaction with the JSON input templates so
# the user does not need to manually edit JSON files when configuring their SAP
# Launchpad access credentials for downloading SAP install media.
#
###############################################################################

# exit immediately if a command fails
# set -o errexit

# exit immediately if an unset variable is used
set -o nounset

# import common functions that are reused across scripts
source util/common_utils.sh


# location of the input JSON template
readonly target_path="deploy/v2"
# readonly target_code="${target_path}/terraform/"
readonly target_template_dir="${target_path}/template_samples"


function main()
{
	check_command_line_arguments "$@"

	local resource_group="$1"
	local template_name="$2"

	edit_json_template_for_resource_group "${resource_group}" "${template_name}"
}


function check_command_line_arguments()
{
	local args_count=$#

	# Check there're just two arguments provided
	if [[ ${args_count} -ne 2 ]]; then
		echo "Available Templates:"
		list_available_templates
		error_and_exit "You must specify 2 command line arguments for the resource group: a resource group name, and the template name"
	fi
}


function list_available_templates()
{
	print_allowed_json_template_names "${target_template_dir}" | grep -v 'rti_only'
}


function check_command_installed()
{
	local cmd="$1"
	local advice="$2"

	local is_cmd_installed
	command -v "${cmd}" > /dev/null
	is_cmd_installed=$?

	local error="This script depends on the '${cmd}' command being installed"
	# append advice if any was provided
	if [[ "${advice}" != "" ]]; then
		error="${error} (${advice})"
	fi

	continue_or_error_and_exit ${is_cmd_installed} "${error}"
}


function edit_json_template_for_resource_group()
{
	local resource_group="$1"
	local template_name="$2"

	# use temp file method to avoid BSD sed issues on Mac/OSX
	# See: https://stackoverflow.com/questions/5694228/sed-in-place-flag-that-works-both-on-mac-bsd-and-linux/5694430#5694430
	local target_json="${target_template_dir}/${template_name}.json"
	local temp_template_json="${target_json}.tmp"

	check_file_exists "${target_json}"

	check_command_installed 'jq' 'Try: https://stedolan.github.io/jq/download/'

	# this is the JSON path in jq format
	local jq_json_path='"infrastructure", "resource_group", "name"'
	local jq_command="jq --arg rg ${resource_group} 'setpath([${jq_json_path}]; \$rg)' ${target_json}"

	# edit JSON template file contents and write to temp file
	eval "${jq_command}" > "${temp_template_json}"

    # replace original JSON template file with temporary edited one
    mv "${temp_template_json}" "${target_json}"
}


# Execute the main program flow with all arguments
main "$@"
