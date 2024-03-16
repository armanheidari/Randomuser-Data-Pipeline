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

source "$dir_path/.venv/bin/activate"

nohup python3 "$dir_path/Python_Files/Add_Timestamp.py" 1>/dev/null 2>/dev/null &

nohup python3 "$dir_path/Python_Files/Add_Label.py" 1>/dev/null 2>/dev/null &

nohup python3 "$dir_path/Python_Files/Add_Database.py" 1>/dev/null 2>/dev/null &

bash $dir_path/Administrator_Scripts/Log.sh "Topic Start Finished Successfully"