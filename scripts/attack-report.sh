#!/bin/bash
set -eou pipefail

auth1="/Users/iygoktas/Desktop/Desk/attack-watch/files-to-be-deleted/auth.log"
auth2="/Users/iygoktas/Desktop/Desk/attack-watch/files-to-be-deleted/qweqwe.log"

fileCheck() {
	if [ -f "$1" ] && [ -r "$1" ]; then
		echo "File exists and readable"
	else 
		echo " $1 is not exists or not readable" >&2
		exit 2
	fi
}

current_date=$(date '+%Y-%m-%d')
server_name=$(hostname)

fileTitle() {
	echo "# $current_date $server_name"
}

fileTitle




