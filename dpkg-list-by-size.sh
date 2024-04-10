#!/bin/sh

# Usage:
#
#  - `./dpkg-list-by-size.sh`:
#      List all packages sorted by size and print their respective size:
#
#  - `./dpkg-list-by-size.sh -t`:
#      Print Total for all packages installed on system: ./dpkg-list-by-size.sh -t

unit="M"
if [ "$1" == '-t' ]
then
    unit=""
fi

output="$(dpkg-query --showformat='${Package}\t${Installed-size}\t${Status}\n' --show |
    awk -v unit="$unit" '
{
    # evaluate installed packages only
    if($3 == "install"){
        packages[$1] = $2
    }
}

END {
    # sort packages by size (change 'asc' to 'desc' to reverse the order)
    PROCINFO["sorted_in"] = "@val_num_asc"
    for (i in packages){
        printf "%05.2f" unit " | %s\n",
        packages[i] / 1024, # convert from kilobytes to megabytes
        i
    }
}
')" &&

if [ "$1" == '-t' ]
then
    awk '{sum += $1} END {print "Total installed packages Size:",sum "M"}' <<< "$output"
else
    sort -rn <<< "$output"
fi
