#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $SCRIPTPATH/helpers.sh


task "provisioning ALL resources"


sh $SCRIPTPATH/provision-compartment.sh
sh $SCRIPTPATH/provision-network.sh
sh $SCRIPTPATH/provision-object-storage-bucket.sh
sh $SCRIPTPATH/provision-custom-resources.sh
sh $SCRIPTPATH/provision-customer-agreement.sh
sh $SCRIPTPATH/provision-compute.sh


log "<= DONE"

load_param "instance_public_ip"
load_param "object_storage_preauth_link"

log " ============== INSTRUCTIONS ============== "
echo ""
echo "1. Download key from $object_storage_preauth_link"
echo "2. Connect to $instance_public_ip with user \"opc\" (ssh opc@$instance_public_ip -i \"path to key\""
echo "3. Run:"
echo "	jupyter notebook --generate-config"
echo "	sed -i "s/#c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '*'/" ~/.jupyter/jupyter_notebook_config.py"
echo "	jupyter notebook password"
echo "	pyspark"
echo "4. Connect to http://$instance_public_ip:8888"


