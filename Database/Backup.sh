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

if [ -f "$dir_path/.env" ]; then
	set -o allexport && source "$dir_path/.env" && set +o allexport
fi

docker exec postgres_project bash -c "pg_basebackup -U ${POSTGRES_USER:-arman} -w -D /backup/standalone-"$(date +%Y-%m-%d_%T%H-%M)" -c fast -P -R"
