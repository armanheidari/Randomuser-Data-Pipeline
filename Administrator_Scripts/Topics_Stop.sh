#!/bin/bash

_parent_dir () {
    path=$1
    depth=$2
    while [ $depth -ne 0 ]; do
        path=$(dirname $path)
        depth=$(($depth - 1))
    done
    echo $path
    return 0
}

dir_path=$(_parent_dir $(readlink -f $0) 2)

for file_name in 2-Add_Label.py 1-Add_Timestamp.py 3-Add_Database.py; do
	for pid in $(
		ps -ax -o pid,command | 
		grep "$dir_path/Python_Files/$file_name" | 
		grep -v "grep" | 
		awk '{print $1}'
	); do
		sudo kill -9 $pid
		bash $dir_path/Administrator_Scripts/Log.sh "[$pid] Killed" -t
	done
done