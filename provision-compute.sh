#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $SCRIPTPATH/helpers.sh


task "provision \"$instance_name\" compute instance"


#get compartment
load_ocid "compartment_id"

#get image-id
load_ocid "instance_image_ocid"

#get vcnid
load_ocid "vcn_id"

#get subnet
load_ocid "vcn_public_subnet_id"


#instance AD

instance_ad=$(oci iam availability-domain list --all --query 'data[?contains(name, `'"${availability_domain}"'`)] | [0].name' --raw-output)
save_param "instance_ad" "$instance_ad"


load_param "public_key"
instance_metadata='{"ssh_authorized_keys": "'$public_key'"}'
log "instance_metadata : $instance_metadata"

instance_ocid=$(oci compute instance launch --availability-domain "$instance_ad" --compartment-id "$compartment_id" --shape "$instance_shape" --subnet-id "$vcn_public_subnet_id" --assign-public-ip true --display-name "$instance_name" --image-id "$instance_image_ocid" --metadata "$instance_metadata" --wait-for-state RUNNING --query 'data.id' --raw-output --user-data-file  "$SCRIPTPATH"/cloud-init/"$instance_cloud_init_file_name" )
save_ocid "instance_ocid" $instance_ocid

instance_public_ip=$(oci compute instance list-vnics --compartment-id "$compartment_id" --instance-id "$instance_ocid" --query 'data[0]."public-ip"' --raw-output)
save_param "instance_public_ip" "$instance_public_ip"
