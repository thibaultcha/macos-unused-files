#!/bin/bash

while getopts "d: -days: s v h -help" opt; do
  case "$opt" in
    d|--days) days=$OPTARG;;
    s) bytes=0;;
	v) verbose=true;;
	h|--help)
		echo "$0 - @thibaultCha 2013"
		echo "-h, --help                show help"
		echo "-d, --days                specify number of days"
		echo "-s, --size                print the total size from files found"
		exit 0
		;;
    \?) exit 1;;
  esac
done

if [ -n "$days" ]
	then
		query="kMDItemLastUsedDate <= \$time.today(-$days)"

		echo "Searching for unused files in the last $days days..."
		list=$(/usr/bin/mdfind `echo "$query"`)

		if [ -n "$verbose" ]
			then echo "$list"
		fi

		lines=$(echo "$list" | wc -l | awk {'print $1 '})
		result="Found $lines files unused in the last $days days."

		if [ -n "$bytes" ] 
			then
				echo "Getting total files size..."
				while read -r line; do
		    		bytes=$(($bytes + $(stat -f "%z" "$line")))
				done <<< "$list"
				result="$result Total: $bytes bytes."
		fi

		echo "$result"
else
	echo "Usage: $0 [-s] [–v] -d <n_days>"
	exit 1
fi
