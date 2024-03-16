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

dir_path=$(_parent_dir $(readlink -f $0) 1)

# Running all stop scripts 
bash $dir_path/Administrator_Scripts/Crone_Remove.sh
bash $dir_path/Administrator_Scripts/Container_Stop.sh
bash $dir_path/Administrator_Scripts/Topics_Stop.sh