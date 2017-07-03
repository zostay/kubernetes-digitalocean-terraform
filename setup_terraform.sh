## Setup terraform envvars
# Usage:
#	. ./setup_terraform.sh

export TF_VAR_number_of_workers=2
export TF_VAR_do_token=$(zostay-get-secret DIGITAL_OCEAN_TOKEN)
export TF_VAR_prefix=phoenix-
export TF_VAR_ssh_private_key="~/.ssh/id_rsa_do_k8s"

function get_ssh_version {
    # ssh -V prints to stderr, redirect
    ssh_ver=$(ssh -V 2>&1)
    [[ -n $ZSH_VERSION ]] && setopt LOCAL_OPTIONS KSH_ARRAYS BASH_REMATCH
    [[ $ssh_ver =~ OpenSSH_([0-9][.][0-9]) ]] && echo "${BASH_REMATCH[1]}"
}


# if ssh version is under 6.9, use -lf, otherwise must use the -E version
if ! awk -v ver="$(get_ssh_version)" 'BEGIN { if (ver < 6.9) exit 1; }'; then
    export TF_VAR_ssh_fingerprint=$(ssh-keygen -lf ~/.ssh/id_rsa_do_k8s.pub | awk '{print $2}')
else
    export TF_VAR_ssh_fingerprint=$(ssh-keygen -E MD5 -lf ~/.ssh/id_rsa_do_k8s.pub | awk '{print $2}' | sed 's/MD5://g')
fi
