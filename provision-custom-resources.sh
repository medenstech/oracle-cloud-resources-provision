#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $SCRIPTPATH/helpers.sh

#get compartment
load_ocid "compartment_id"

#generate keypair
task "generating auth key pair"
cat /dev/zero | ssh-keygen -q -N ""
echo ""
public_key=$(cat ~/.ssh/id_rsa.pub)
save_param "public_key" "$public_key"


#upload keys to object storage
task "upload keys to object storage"
echo "y" | oci os object put --bucket-name $object_storage_bucket_name --name keys/id_rsa --file ~/.ssh/id_rsa --metadata '{"key-type":"private","uploaded-by":"automation"}'
echo "y" | oci os object put --bucket-name $object_storage_bucket_name --name keys/id_rsa.pub --file ~/.ssh/id_rsa.pub --metadata '{"key-type":"public","uploaded-by":"automation"}'


#create pre-authenticated download links for private key
task "provision pre-authenticated path to auth key"
object_storage_preauth_link="https://objectstorage.REGION.oraclecloud.com/PATH"
time_expires=$(date -d "+7 days" +"%Y-%m-%dT%H:%MZ")
access_uri=$(oci os preauth-request create --name "download key" --access-type ObjectRead --bucket-name $object_storage_bucket_name --time-expires $time_expires --object-name "keys/id_rsa" --query data.\"access-uri\")
home_region=$(oci iam region-subscription list --raw-output --query "data [?\"is-home-region\"].\"region-name\" | [0]" )
object_storage_preauth_link=${object_storage_preauth_link/\/PATH/$access_uri}
object_storage_preauth_link=${object_storage_preauth_link/REGION/$home_region}
object_storage_preauth_link=${object_storage_preauth_link//\"}
save_param "object_storage_preauth_link" "$object_storage_preauth_link"

