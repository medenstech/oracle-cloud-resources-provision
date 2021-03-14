#!/bin/sh

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $SCRIPTPATH/setup.config
#echo "running in $SCRIPTPATH"

log () {
	t_date=$(date '+%Y-%m-%d %H:%M:%S')
	echo -e "\e[1;32m[$t_date] $1\e[0m"
	}

task () {
	log "=> $1"
	}
	
save_to_temp () {
	mkdir -p $SCRIPTPATH/"$temp_folder"
	echo "$1=\"$2\"" >$SCRIPTPATH/"$temp_folder"/"$1$3"
	}

save_param () {
	save_to_temp "$1" "$2" ".param"
        log "$1 : $2"
	}


save_ocid () {
	save_to_temp "$1" "$2" ".ocid"
	log "$1 : $2"
	}

load_ocid () {
	. $SCRIPTPATH/"$temp_folder"/"$1.ocid"
	log "$1 : ${!1}"
	}

load_param () {
        . $SCRIPTPATH/"$temp_folder"/"$1.param"
        log "$1 : ${!1}"
        }
