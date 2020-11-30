#!/bin/bash

# Usage
#   /path/to/util/check_bom.sh /other/path/to/bom.yml

command -v yamllint >/dev/null || sudo apt install -y yamllint
command -v ansible-lint >/dev/null || sudo apt install -y ansible-lint

yamllint $1 && echo "... yamllint [ok]" || echo "... yamllint [errors]"
ansible-lint $1 && echo "... ansible-lint [ok]" || echo "... ansible-lint [errors]"

ansible-playbook --extra-vars "bom_name=$1" check_bom.yml
