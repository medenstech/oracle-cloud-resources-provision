#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $SCRIPTPATH/helpers.sh


task "provision \"$compartment_name\" compartment"

#create compartment
root_compartment_id=$(oci iam compartment list --all --compartment-id-in-subtree true --access-level ACCESSIBLE --include-root --raw-output --query "data[?contains(\"id\",'tenancy')].id | [0]")

save_ocid  "root_compartment_id"  $root_compartment_id 


compartment_id=$(oci iam compartment list --all --compartment-id-in-subtree true --access-level ACCESSIBLE --include-root --raw-output --query "data[?\"lifecycle-state\" == 'ACTIVE'] | [?contains(\"name\",'$compartment_name')].id | [0]")
[ -z "$compartment_id" ] && \
compartment_id=$(oci iam compartment create --name "$compartment_name" --description "$compartment_description" --compartment-id $root_compartment_id --query data.id)
compartment_id=${compartment_id//\"}


save_ocid "compartment_id" $compartment_id

