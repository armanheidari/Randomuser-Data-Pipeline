#! /bin/bash

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

_save_log () {
    echo "$(date +"%Y-%m-%d %H:%M:%S"): $1" >> $dir_path/log/info.log
}

_save_table_log () {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S"): \n$1" >> $dir_path/log/info.log
}

_print_log () {
    size=${#1}

    count=0
    while [ $count -lt $(($size+2)) ]; do
        printf "-"
        count=$(($count+1))
    done

    printf "\n"

    printf "|%s|" "$1"

    printf "\n"

    count=0
    while [ $count -lt $(($size+2)) ]; do
        printf "-"
        count=$(($count+1))
    done

    printf "\n"
}

_print_table_log () {
    echo -e "$1"
}


dir_path=$(_parent_dir $(readlink -f $0) 2)

log_text=$1

shift

table=0

case $1 in
-t | --table)
    table=1
    shift
    ;;
*) 
    echo "Unknown flag"
    exit 1
    ;;
esac

if [ $table -eq 0 ]; then
    _save_log "$log_text"
else
    _save_table_log "$log_text"
fi