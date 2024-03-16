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

bash $dir_path/Administrator_Scripts/Log.sh "Stopping The Containers..."

docker compose -f $dir_path/docker-compose.yml --profile project down
