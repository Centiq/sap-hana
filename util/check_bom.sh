#!/bin/bash

# Usage
#   /path/to/util/check_bom.sh /other/path/to/bom.yml

YAML_LINT=$(command -v yamllint) || echo "yamllint not found. Try sudo apt install -y yamllint and try again"
ANSIBLE_LINT=$(command -v ansible-lint) || echo "ansible-lint not found. Try sudo apt install -y ansible-lint and try again"

[[ -n ${YAML_LINT} ]] && ${YAML_LINT} $1 && echo "... yamllint [ok]" || echo "... yamllint [errors]"
[[ -n ${ANSIBLE_LINT} ]] && ${ANSIBLE_LINT} $1 && echo "... ansible-lint [ok]" || echo "... ansible-lint [errors]"

ansible-playbook --extra-vars "bom_name=$1" check_bom.yml |
  sed -n -e '/^failed/,/^}/p' |
  sed -n -e '/"msg":/s/^.*"msg": "\(.*\)".*$/- \1/p'
