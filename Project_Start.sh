#!/bin/bash

if [ "$EUID" -eq 0 ];then
	echo -e "Please do not run the script with sudo privilage, or as root user"
    exit 1
fi

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

bash $dir_path/Administrator_Scripts/Log.sh "Application is running"

if [ -f "$dir_path/.env" ]; then
	set -o allexport && source "$dir_path/.env" && set +o allexport
    if [ -n "$KAFKA_TOPICS" ]; then
        if ! grep -q "^\w\+:[[:digit:]]\+:[[:digit:]]\+\(,\w\+:[[:digit:]]\+:[[:digit:]]\+\)*$" <<< "$KAFKA_TOPICS"; then
            bash $dir_path/Administrator_Scripts/Log.sh "The pattern of [KAFKA_TOPICS] environment variable is not correct"
            exit 1
        fi
    fi
fi

bash $dir_path/Project_Stop.sh

bash $dir_path/Administrator_Scripts/Cron_Add.sh

bash $dir_path/Administrator_Scripts/Container_Start.sh

bash $dir_path/Administrator_Scripts/Log.sh "Checking Kafka Status..."

source $dir_path/.venv/bin/activate

python3 $dir_path/Python_Files/Kafka_HealthCheck.py 1>/dev/null 2>/dev/null

if [ "$?" -ne "0" ]; then
    bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while connecting to Kafka"
    bash $dir_path/Project_Stop.sh
    exit 1
fi

bash $dir_path/Administrator_Scripts/Log.sh "Kafka Is Ready"

deactivate

bash $dir_path/Administrator_Scripts/Log.sh "Loading Nocodb..."

counter=0
flag=0
while [ $counter -lt 30 -a $flag -ne 1 ]; do
	if [ "$(curl -X GET -LsI -o /dev/null -w "%{http_code}" "http://localhost:${NOCODB_HOST_PORT:-8080}" 2>/dev/null)" -eq "200" ]; then
		sleep 1
		flag=1
	fi
	counter=$(($counter + 1))
	sleep 1
done

if [ $flag -eq 0 ]; then
	bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while connecting to Nocodb"
	exit 1
fi

bash $dir_path/Administrator_Scripts/Log.sh "Nocodb Is Ready"

bash $dir_path/Administrator_Scripts/Log.sh "Starting Topic Scripts..."

nohup bash $dir_path/Administrator_Scripts/Topics_Start.sh 1>/dev/null 2>/dev/null