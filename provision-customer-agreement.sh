#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $SCRIPTPATH/helpers.sh

echo -e "\e[1;32m running in $SCRIPTPATH \e[0m"
task "provision customer agreement for \"$instance_image_name\" "


#get compartment
load_ocid "compartment_id"


instance_image_ocid_listing=$(oci compute pic listing list --all --raw-output --query "data[?contains(\"display-name\", '$instance_image_name')].\"listing-id\" | [0] ")
save_ocid "instance_image_ocid_listing" $instance_image_ocid_listing


version_list=$(oci compute pic version list --listing-id "$instance_image_ocid_listing" \
    --query 'sort_by(data,&"time-published")[*].join('"'"' '"'"',["listing-resource-version", "listing-resource-id"]) | join(`\n`, reverse(@))' \
    --raw-output)
instance_image_ocid=""
while read instance_image_version instance_image_ocid ;do
# Ensure image is available for shape
available=$(oci compute pic version get --listing-id "$instance_image_ocid_listing" \
  --resource-version "$instance_image_version" \
  --query 'data."compatible-shapes"|contains(@, `'$instance_shape'`)' \
  --raw-output)
if [[ "${available}" = "true" ]]; then
  break
fi
log "Version $instance_image_version not available for your shape; skipping"
done <<< "${version_list}"

save_ocid "instance_image_version" $instance_image_version
save_ocid "instance_image_ocid" $instance_image_ocid


instance_image_agreement=$(oci compute pic agreements get --listing-id "$instance_image_ocid_listing"  --resource-version  "$instance_image_version" --query '[data."oracle-terms-of-use-link", data.signature, data."time-retrieved"] | join(`\n`,@)' --raw-output)

instance_image_signature=$(echo $instance_image_agreement | awk '{print $2;}')
save_ocid "instance_image_signature" $instance_image_signature

instance_image_oracle_terms_of_use_link=$(echo $instance_image_agreement | awk '{print $1;}')
save_ocid "instance_image_oracle_terms_of_use_link" $instance_image_oracle_terms_of_use_link

instance_image_oracle_terms_of_use_time_retrieved=$(echo $instance_image_agreement | awk '{print $3;}')
instance_image_oracle_terms_of_use_time_retrieved=$(echo $instance_image_oracle_terms_of_use_time_retrieved | sed 's/\(.*\)000/\1/')
instance_image_oracle_terms_of_use_time_retrieved=$(echo $instance_image_oracle_terms_of_use_time_retrieved | sed 's/\(.*\):/\1/')
save_ocid "instance_image_oracle_terms_of_use_time_retrieved" $instance_image_oracle_terms_of_use_time_retrieved


instance_image_subscription=$(oci compute pic subscription create --listing-id "$instance_image_ocid_listing" --resource-version  "$instance_image_version" --compartment-id $compartment_id --signature "$instance_image_signature" --oracle-tou-link $instance_image_oracle_terms_of_use_link --time-retrieved "$instance_image_oracle_terms_of_use_time_retrieved" --query "data.\"listing-id\" " --raw-output)

save_ocid "instance_image_subscription" $instance_image_subscription


