#!/bin/bash
set -eou pipefail

# shellcheck source=/dev/null
source "/etc/attack-watch/private.env"

authLog="/var/log/auth.log"
accessLog="/var/log/nginx/access.log"
reportDir="${1:-/srv/reports}"

fnFileCheck() {
	if ! { [ -f "$1" ] && [ -r "$1" ]; }; then
		echo " $1 is not exists or not readable" >&2
		exit 2
	fi
}
fnFileCheck "$authLog"
fnFileCheck "$accessLog"

server_name=$(hostname)
current_date=$(date '+%Y-%m-%d')

reportTitle="${reportDir}/attackwatch-${current_date}.md"
mkdir -p "$reportDir"

fileTitle() {
	echo "# $current_date $server_name"
}
fnTotalCount() {
	totalCount=$(grep -ce "authenticating user" -e "Invalid user" "$authLog" || true)
	echo "## Total Attempt:" "$totalCount"
}
fnDifferentIP() {
	totalDiffIP=$(grep -e "Invalid user" -e "authenticating user" "$authLog" | grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort -u | wc -l | tr -d '[:space:]' || true)
	echo "## Amount of Different IP's" "$totalDiffIP"
}
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

    echo "## Most Used IP's and Top Countries:"
    echo "$topIP"
}
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
	echo "## Most Navigated Paths:"
    echo "$paths"
}
{
    fileTitle
    fnTotalCount
    fnDifferentIP
    fnTopUsernames
    fnTopIPTopCountry
    fnAccessedPaths
} > "$reportTitle"

find "$reportDir" -maxdepth 1 -type f -name 'attackwatch-*.md' -mtime +30 -delete