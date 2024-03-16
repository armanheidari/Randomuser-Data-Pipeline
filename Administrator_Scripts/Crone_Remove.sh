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

bash $dir_path/Administrator_Scripts/Log.sh "Deleting from cron-job: [0-Get_Data.py]"

crontab -l | grep -v "$dir_path/Python_Files/0-Get_Data.py" | grep -v "$dir_path/Database/Backup.sh" | crontab -
