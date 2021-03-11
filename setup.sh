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

echo ""
log " ============== INSTRUCTIONS ============== "
log "1. Download key from $object_storage_preauth_link"
log "2. Wait about 20 minutes till the instance finish the boot process and software install (connection will be refused till the end of the install)"
log "3. Connect to $instance_public_ip with user \"opc\" (ssh opc@$instance_public_ip -i \"path to key\""
log "4. Run:"
log "   jupyter notebook --generate-config"
log "	sed -i \"s/#c.NotebookApp.ip = 'localhost'/c.NotebookApp.ip = '*'/\" ~/.jupyter/jupyter_notebook_config.py"
log "   jupyter notebook password"
log "   pyspark"
log "5. Connect to http://$instance_public_ip:8888"
log " ========================================== "
