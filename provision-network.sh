#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $SCRIPTPATH/helpers.sh


task "provision \"$vcn_name\" network"


#get compartment
load_ocid "compartment_id"


#create VCN
vcn_id=$(oci network vcn list --compartment-id $compartment_id --raw-output --query "data[?contains(\"display-name\",'$vcn_name')].id | [0]")
[ -z "$vcn_id" ] && \
vcn_id=$(oci network vcn create --cidr-block $vcn_cidr --display-name "$vcn_name" --compartment-id $compartment_id --wait-for-state AVAILABLE --query data.id )
vcn_id=${vcn_id//\"}

save_ocid "vcn_id" $vcn_id


#create Internet Gateway
task "provision \"$vcn_internet_gateway_name\" internet gateway"
vcn_internet_gateway_id=$(oci network internet-gateway list --compartment-id $compartment_id --raw-output --query "data[?contains(\"display-name\",'$vcn_internet_gateway_name')].id | [0]")
[ -z "$vcn_internet_gateway_id" ] && \
vcn_internet_gateway_id=$(oci network internet-gateway create --display-name "$vcn_internet_gateway_name" --compartment-id $compartment_id --is-enabled true --vcn-id $vcn_id --wait-for-state AVAILABLE --query data.id)
vcn_internet_gateway_id=${vcn_internet_gateway_id//\"}
save_ocid "vcn_internet_gateway_id" $vcn_internet_gateway_id


#create NAT Gateway
task "provision \"$vcn_nat_gateway_name\" NAT gateway "
vcn_nat_gateway_id=$(oci network nat-gateway list --compartment-id $compartment_id --raw-output --query "data[?contains(\"display-name\",'$vcn_nat_gateway_name')].id | [0]")
[ -z "$vcn_nat_gateway_id" ] && \
vcn_nat_gateway_id=$(oci network nat-gateway create --display-name "$vcn_nat_gateway_name" --compartment-id $compartment_id --vcn-id $vcn_id --wait-for-state AVAILABLE  --query data.id)
vcn_nat_gateway_id=${vcn_nat_gateway_id//\"}
save_ocid "vcn_nat_gateway_id" $vcn_nat_gateway_id


#create public subnet
task "provision \"$vcn_public_subnet_name\" subnet "
#create public security list
vcn_public_security_list_id=$(oci network security-list list --compartment-id $compartment_id --vcn-id $vcn_id --raw-output --query "data[?contains(\"display-name\",'$vcn_public_security_list_name')].id | [0]")
[ -z "$vcn_public_security_list_id" ] && \
vcn_public_security_list_id=$(oci network security-list create --display-name "$vcn_public_security_list_name" --compartment-id $compartment_id --egress-security-rules "$vcn_public_security_list_egress" --ingress-security-rules "$vcn_public_security_list_ingress" --vcn-id $vcn_id  --wait-for-state AVAILABLE --query data.id )
vcn_public_security_list_id=${vcn_public_security_list_id//\"}
save_ocid "vcn_public_security_list_id"  $vcn_public_security_list_id


#create public route table
vcn_public_route_table_rule=${vcn_public_route_table_rule/ocid1.internetgateway.oc1/$vcn_internet_gateway_id}
vcn_public_route_table_id=$(oci network route-table list --compartment-id $compartment_id --vcn-id $vcn_id --raw-output --query "data[?contains(\"display-name\",'$vcn_public_route_table_name')].id | [0]")
[ -z "$vcn_public_route_table_id" ] && \
vcn_public_route_table_id=$(oci network route-table create --compartment-id $compartment_id  --vcn-id $vcn_id --display-name "$vcn_public_route_table_name" --route-rules "$vcn_public_route_table_rule"  --wait-for-state AVAILABLE --query data.id)
vcn_public_route_table_id=${vcn_public_route_table_id//\"}
save_ocid "vcn_public_route_table_id" $vcn_public_route_table_id


#create public subnet
vcn_public_security_list_ids=${vcn_public_security_list_ids/ID/$vcn_public_security_list_id}
vcn_public_subnet_id=$(oci network subnet list --compartment-id $compartment_id --vcn-id $vcn_id --raw-output --query "data[?contains(\"display-name\",'$vcn_public_subnet_name')].id | [0]")
[ -z "$vcn_public_subnet_id" ] && \
vcn_public_subnet_id=$(oci network subnet create --cidr-block "$vcn_public_subnet_cidr" --compartment-id $compartment_id  --vcn-id $vcn_id --display-name "$vcn_public_subnet_name" --prohibit-public-ip-on-vnic false --route-table-id "$vcn_public_route_table_id" --security-list-ids "$vcn_public_security_list_ids" --wait-for-state AVAILABLE --query data.id)
vcn_public_subnet_id=${vcn_public_subnet_id//\"}
save_ocid "vcn_public_subnet_id" $vcn_public_subnet_id


#create private subnet
task "provision \"$vcn_private_subnet_name\" subnet "
#create private security list
vcn_private_security_list_id=$(oci network security-list list --compartment-id $compartment_id --vcn-id $vcn_id --raw-output --query "data[?contains(\"display-name\",'$vcn_private_security_list_name')].id | [0]")
[ -z "$vcn_private_security_list_id" ] && \
vcn_private_security_list_id=$(oci network security-list create --display-name "$vcn_private_security_list_name" --compartment-id $compartment_id --egress-security-rules "$vcn_private_security_list_egress" --ingress-security-rules "$vcn_private_security_list_ingress" --vcn-id $vcn_id  --wait-for-state AVAILABLE --query data.id ) && \
vcn_private_security_list_id=${vcn_private_security_list_id//\"}
save_ocid "vcn_private_security_list_id" $vcn_private_security_list_id


#create private route table
vcn_private_route_table_rule=${vcn_private_route_table_rule/ocid1.internetgateway.oc1/$vcn_internet_gateway_id}
vcn_private_route_table_id=$(oci network route-table list --compartment-id $compartment_id --vcn-id $vcn_id --raw-output --query "data[?contains(\"display-name\",'$vcn_private_route_table_name')].id | [0]")
[ -z "$vcn_private_route_table_id" ] && \
vcn_private_route_table_id=$(oci network route-table create --compartment-id $compartment_id  --vcn-id $vcn_id --display-name "$vcn_private_route_table_name" --route-rules "$vcn_private_route_table_rule"  --wait-for-state AVAILABLE --query data.id)
vcn_private_route_table_id=${vcn_private_route_table_id//\"}
save_ocid "vcn_private_route_table_id" $vcn_private_route_table_id


#create private subnet
vcn_private_security_list_ids=${vcn_private_security_list_ids/ID/$vcn_private_security_list_id}
vcn_private_subnet_id=$(oci network subnet list --compartment-id $compartment_id --vcn-id $vcn_id --raw-output --query "data[?contains(\"display-name\",'$vcn_private_subnet_name')].id | [0]")
[ -z "$vcn_private_subnet_id" ] && \
vcn_private_subnet_id=$(oci network subnet create --cidr-block "$vcn_private_subnet_cidr" --compartment-id $compartment_id  --vcn-id $vcn_id --display-name "$vcn_private_subnet_name" --route-table-id "$vcn_private_route_table_id" --security-list-ids "$vcn_private_security_list_ids" --wait-for-state AVAILABLE --query data.id)
vcn_private_subnet_id=${vcn_private_subnet_id//\"}
save_ocid "vcn_private_subnet_id" $vcn_private_subnet_id

