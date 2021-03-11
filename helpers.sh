#!/bin/sh

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $SCRIPTPATH/setup.config
echo "running in $SCRIPTPATH"

log () {
	echo -e "\e[1;32m$1\e[0m"
	}

task () {
	log "=> $1"
	}
	
save_param () {
	mkdir -p $SCRIPTPATH/"$temp_folder"
	echo "$1=$2" >$SCRIPTPATH/"$temp_folder"/"$1.$3"
}

save_ocid () {
	save_param $1 $2 "ocid"
	log "$1 : $2"
	}

load_ocid () {
	. $SCRIPTPATH/"$temp_folder"/"$1.ocid"
	log "$1 : ${!1}"
	}
