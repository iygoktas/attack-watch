#!/bin/bash
set -eou pipefail

source "/Users/iygoktas/Desktop/Desk/attack-watch/config/private.env"

authLog="/Users/iygoktas/Desktop/Desk/attack-watch/files-to-be-deleted/auth.log"
accessLog="/Users/iygoktas/Desktop/Desk/attack-watch/files-to-be-deleted/access.log"

fnFileCheck() {
	if ! { [ -f "$1" ] && [ -r "$1" ]; }; then
		echo " $1 is not exists or not readable" >&2
		exit 2
	fi
}
fnFileCheck "$authLog"
fnFileCheck "$accessLog"

fileTitle() {
	server_name=$(hostname)
	current_date=$(date '+%Y-%m-%d')
	echo "# $current_date $server_name"
}
fileTitle

fnTotalCount() {
	totalCount=$(grep -e "authenticating user" -e "Invalid user" "$authLog" | wc -l | tr -d '[:space:]' || true)
	echo "## Total Attempt:" "$totalCount"
}
fnTotalCount

fnDifferentIP() {
	totalDiffIP=$(grep -e "Invalid user" -e "authenticating user" "$authLog" | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort -u | wc -l | tr -d '[:space:]' || true)
	echo "## Amount of Different IP's" "$totalDiffIP"
}
fnDifferentIP

fnTopUsernames() {
	topUsernames=$(grep -E "Invalid user|authenticating user" "$authLog" |
        sed -nE \
            -e 's/.*Invalid user ([^ ]+) from .*/\1/p' \
            -e 's/.*authenticating user ([^ ]+) .*/\1/p' |
        sort |
        uniq -c |
        sort -nr |
        head -10 || 
	true) 
	echo "## Top Usernames:"
	echo "$topUsernames"
}
fnTopUsernames

fnTopIPTopCountry() {
    topIP=$(grep -e "Invalid user" -e "authenticating user" "$authLog" |
        grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' |
        sort |
        uniq -c |
        sort -nr |
        head -10 |
        while read -r count ip; do
            country=$(whois "$ip" | grep -im1 '^country:' | awk '{print $2}')
            echo "IP: $ip | Attempts: $count | Country: ${country:-Unknown}"
        done || true)

    echo "$topIP"
}
fnTopIPTopCountry

fnAccessedPaths() {
	paths=$(awk -v myip="$MY_IP" -v azureip="$AZURE_IP" \
        '$1 != myip && $1 != azureip && $1 != "127.0.0.1" {print $0}' "$accessLog" |
        awk -F'"' '{print $2}' |
        awk '{print $2}' |
        awk '$1 ~ /^\//' |
        sort |
        uniq -c |
        sort -nr |
        head -10 ||
        true
    )
	echo "$paths"
}
fnAccessedPaths