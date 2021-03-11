#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $SCRIPTPATH/helpers.sh

#get compartment
load_ocid "compartment_id"


#create object storage
task "provision \"$object_storage_bucket_name\" object storage bucket"
oci os bucket create --compartment-id $compartment_id --name $object_storage_bucket_name
