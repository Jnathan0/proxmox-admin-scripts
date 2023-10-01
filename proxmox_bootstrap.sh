#!/bin/bash

source env.sh
ENABLE_CONFIG=''
TEMPLATE_FILES=()

function gather_pipenv() {
    if [ ! -d './env' ]; then
        echo "Creating pip env and installing requirements..."
        python3 -m venv env
        source ./env/bin/activate
        pip install -r requirements.txt
    else
        echo "Found existing pip venv, skipping dependency install..."
    fi
}

function cleanup_pipenv() {
    if [ -d ./env ] && [ -z "${PERSIST_PIPENV:-}" ]; then
        echo "Cleaning up venv..."
        pwd
        rm -R -f ./env
    else
        echo "Persisting pip venv for future use..."
    fi
}

function show_help() {
    cat >&2 <<EOF
$0 --enable-config --template-file FILE
Configures Proxmox datacenter and installs VM template bases via ansible. 
Optional
    -c --enable-config
        Enable configuration based on the scripts and playbooks in the ./config folder
    -t PLAYBOOK --template-files PLAYBOOK
        Apply the given ansible playboos in the ./templates directory by name to the remote Proxmox datacenter. Can be reused 
        multiple times (e.x. -t template.yml -t template2.yml)
EOF
    exit 1
}

while [ "$#" -gt 0 ]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -c|--enable-config)
            ENABLE_CONFIG=1
            shift 2
            ;;
        -t|--template-file)
            TEMPLATE_FILES+=("$2")
            shift 2
            ;;
        *)
            echo "ERROR: Invalid option $1 provided." >&2
            show_help
            ;;
    esac
done

gather_pipenv
source ./env/bin/activate
for playbook in ${TEMPLATE_FILES[@]}
do
    ansible-playbook -vvv -u "${PROXMOX_USER}" -i "${PROXMOX_REMOTE_HOSTS}", ./templates/$playbook
done
cleanup_pipenv