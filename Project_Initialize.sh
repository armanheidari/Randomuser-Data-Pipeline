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

# Access .env variables in shell script
if [ -f "$dir_path/.env" ]; then
	set -o allexport && source "$dir_path/.env" && set +o allexport
fi

sudo mkdir -p $dir_path/Database/Data/Postgres
sudo mkdir -p $dir_path/Database/Data/Nocodb
mkdir -p $dir_path/Administrator_Scripts/Nocodb
mkdir -p $dir_path/log

# Create Log files
touch $dir_path/log/error.log
touch $dir_path/log/info.log

bash $dir_path/Administrator_Scripts/Log.sh "Project Initializer Started"

# ---------------------------------------------------------------------

_permiter () {
	f_name=$1
	extension=$2

	if [ -f $f_name ]; then
		sudo chmod a+x $f_name
	
	elif [ -d "$dir_path/$f_name" ]; then
		if [ -z "$extension" ]; then
			echo "Extension Type Must Be Passed"
			exit 1
		else
			find "$dir_path/$f_name" -type f -iname "*.$extension" | xargs chmod a+x
		fi
	fi
}

bash $dir_path/Administrator_Scripts/Log.sh "Adding Execution Permission..."

_permiter "$dir_path/Python_Files/0-Get_Data.py"
_permiter "$dir_path/Project_Stop.sh"
_permiter "$dir_path/Project_Start.sh"
_permiter "$dir_path/Database/Backup.sh"
_permiter Administrator_Scripts sh

# ---------------------------------------------------------------------

bash $dir_path/Administrator_Scripts/Log.sh "Checking Dependencies..."

_check_dependency() {
	bash -c "$1 --version 1>/dev/null 2>/dev/null"
	if [ $? -ne 0 ]; then
		echo -e "$1 is not installed.\n\tPlease visit $2 for installation."
		exit 1
	fi
}

bash $dir_path/Administrator_Scripts/Log.sh "[docker]"
_check_dependency docker "https://docs.docker.com/engine/install/"

bash $dir_path/Administrator_Scripts/Log.sh "[python]"
_check_dependency python3 "https://www.python.org/"

apt_update=0

bash $dir_path/Administrator_Scripts/Log.sh "[crontab]"
bash -c "crontab --version 1>/dev/null 2>/dev/null"
if [ $? -eq 127 ]; then
	echo "crontab is not installed. Please wait ..."
	sudo apt-get install -y cron
	if [ $? -ne 0 ]; then
		sudo apt-get update
		apt_update=1
		sudo apt-get install -y cron
		if [ $? -ne 0 ]; then
			echo "There was a problem while installing cron"
			exit 1
		fi
	fi
fi

sudo systemctl start cron 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
	sudo service cron start 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		echo "There was a problem while starting cron service"
		exit 1
	fi
fi

# Must be updated for postgres to start correctly
sudo apt-get install -y libpq-dev

if [ $? -ne 0 ]; then
	if [ $apt_update -ne 1 ]; then
		sudo apt-get update
	fi
	sudo apt-get install -y libpq-dev
	if [ $? -ne 0 ]; then
    	echo "There was a problem while installing libpq-dev"
    	exit 1
	fi
fi

# ---------------------------------------------------------------------

bash $dir_path/Administrator_Scripts/Log.sh "Creating Python Virtual Environment..."


if [ -d "$dir_path/.venv" ]; then
	source $dir_path/.venv/bin/activate
	if [ $? -ne 0 ]; then
		sudo chmod a+x $dir_path/.venv/bin/activate
		if [ $? -ne 0 ]; then
			bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while adding execute permission."
			exit 1
		fi
		
		source $dir_path/.venv/bin/activate
		if [ $? -ne 0 ]; then
			bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while activating virtual environment"
			exit 1
		fi

		pip install poetry==1.8.2
		if [ $? -eq 0 ]; then
			poetry shell
			if [ $? -ne 0 ]; then
				echo "There was a problem while activating poetry shell"
				exit 1
			fi
			
			poetry install --no-root
			if [ $? -ne 0 ]; then
				bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while installing packages"
				exit 1
			fi
		else
			bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while installing poetry using pip"
			exit 1
		fi

	else
		pip install poetry==1.8.2
		if [ $? -eq 0 ]; then
			poetry shell
			if [ $? -ne 0 ]; then
				bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while activating poetry shell"
				exit 1
			fi
			
			poetry install --no-root
			if [ $? -ne 0 ]; then
				bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while installing packages"
				exit 1
			fi
		else
			bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while installing poetry using pip"
			exit 1
		fi
	fi
else
	python3 -m venv $dir_path/.venv
	if [ $? -eq 0 ]; then
		sudo chmod a+x $dir_path/.venv/bin/activate
		if [ $? -ne 0 ]; then
			exit 1
		fi
		
		source $dir_path/.venv/bin/activate
		if [ $? -ne 0 ]; then
			exit 1
		fi

		pip install poetry==1.8.2
		if [ $? -eq 0 ]; then
			poetry shell
			if [ $? -ne 0 ]; then
				bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while activating poetry shell"
				exit 1
			fi
			
			poetry install --no-root
			if [ $? -ne 0 ]; then
				echo "There was a problem while installing packages"
				exit 1
			fi
		else
			echo "There was a problem while installing poetry using pip"
			exit 1
		fi
	else
		echo "Creating python virtual environment"
		sudo rm -rf $dir_path/.venv
		sudo apt-get install -y python3-venv
		
		if [ $? -eq 0 ]; then
			sudo chmod a+x $dir_path/.venv/bin/activate
			if [ $? -ne 0 ]; then
				exit 1
			fi
			
			source $dir_path/.venv/bin/activate
			if [ $? -ne 0 ]; then
				exit 1
			fi

			pip install poetry==1.8.2
			if [ $? -eq 0 ]; then
				poetry shell
				if [ $? -ne 0 ]; then
					echo "There was a problem while activating poetry shell"
					exit 1
				fi
				
				poetry install --no-root
				if [ $? -ne 0 ]; then
					echo "There was a problem while installing packages"
					exit 1
				fi
			else
				echo "There was a problem while installing poetry using pip"
				exit 1
			fi
		else
			echo "There was a problem while creating pyton virtual environment"
			exit 1
		fi
	fi
fi


docker compose -f $dir_path/docker-compose.yml --profile=nocodb down
docker compose -f $dir_path/docker-compose.yml --profile=nocodb up -d

bash $dir_path/Administrator_Scripts/Log.sh "Checking Nocodb..."

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

python3 "$dir_path/Python_Files/Noco_Create_Base.py" 1>/dev/null 2>/dev/null

if [ $? -ne 0 ]; then
	echo "There was a problem while creating nocodb base"
	docker compose -f $dir_path/docker-compose.yml --profile=nocodb down
	exit 1
fi

python3 "$dir_path/Python_Files/Noco_Create_Table.py" 1>/dev/null 2>/dev/null
if [ $? -ne 0 ]; then
	echo "There was a problem while creating nocodb table"
	docker compose -f $dir_path/docker-compose.yml --profile=nocodb down
	exit 1
fi

docker compose -f $dir_path/docker-compose.yml --profile=nocodb down

deactivate

bash $dir_path/Administrator_Scripts/Log.sh "Libraries Installation Finished"

# ---------------------------------------------------------------------

bash $dir_path/Administrator_Scripts/Log.sh "Building Docker Container..."

docker compose -f $dir_path/docker-compose.yml --profile db down
docker compose -f $dir_path/docker-compose.yml --profile db up -d

bash $dir_path/Administrator_Scripts/Log.sh "Checking Database Status..."
counter=0
flag=0
while [ $counter -lt 30 -a $flag -ne 1 ]; do
	bash -c "docker exec postgres_project pg_isready -U ${POSTGRES_USER:-arman} -d ${POSTGRES_DB:-postgres} -h ${POSTGRES_HOST:-localhost} -q" 1>/dev/null 2>/dev/null
	if [ $? -ne 0 ]; then
		counter=$(($counter + 1))
		bash $dir_path/Administrator_Scripts/Log.sh 'Postgres is not ready'
		sleep 1
		continue
	fi

	bash $dir_path/Administrator_Scripts/Log.sh 'Postgres is ready'
	flag=1
done

if [ $flag -eq 0 ]; then
	bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while connecting to the database"
	sudo rm -rf $dir_path/Data/Postgres
	exit 1
fi

bash $dir_path/Administrator_Scripts/Log.sh "Database Is Ready"


bash $dir_path/Administrator_Scripts/Log.sh "Checking Schema..."

counter=0
flag=0
while [ $counter -lt 30 -a $flag -ne 1 ]; do
	if [ $(docker exec postgres_project bash -c "psql -U ${POSTGRES_USER:-arman} -d ${POSTGRES_DB:-postgres} -h ${POSTGRES_HOST:-localhost} -c \"
		SELECT 1
		FROM information_schema.TABLES AS t
		WHERE t.table_name = 'users' AND
		t.table_schema = 'arman';\" | grep -c '(1 row)'") -lt 1 ]; then
		counter=$(($counter + 1))
		docker exec postgres_project bash -c "psql -U ${POSTGRES_USER:-arman} -d ${POSTGRES_DB:-postgres} -h ${POSTGRES_HOST:-localhost} < /code/Database.sql 1>/dev/null 2>/dev/null"
		sleep 1
		continue
	fi
	flag=1
done

if [ $flag -eq 0 ]; then
	bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while creating [${POSTGRES_SCHEMA:-arman}] schema and/or [users] table"
	sudo rm -rf $dir_path/Data/Postgres
	exit 1
fi

bash $dir_path/Administrator_Scripts/Log.sh "Schema Is Correct"

# ---------------------------------------------------------------------

bash $dir_path/Administrator_Scripts/Log.sh "Creating Initial Backup"

bash $dir_path/Database/Backup.sh

if [ $? -ne 0 ]; then
	bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while creating initaial backup"
	sudo rm -rf $dir_path/Data/Postgres
	exit 1
fi

bash $dir_path/Administrator_Scripts/Log.sh "Adding Archive Settings To Postgresql.conf"

if ! [ $(
	docker exec postgres_project bash -c "cat /var/lib/postgresql/data/postgresql.conf" | 
	grep -c "^archive_mode = on$") -ge 1 ]; then

	docker exec postgres_project bash -c " echo -e \"
	wal_level = replica
	archive_mode = on
	archive_command = 'test ! -f /archive/%f && cp %p /archive/%f'\" >> /var/lib/postgresql/data/postgresql.conf"

	if [ $? -ne 0 ]; then
		bash $dir_path/Administrator_Scripts/Log.sh "There was a problem while adding archive settings"
		exit 1
	fi
else
	bash $dir_path/Administrator_Scripts/Log.sh "Archive setting is already set"
fi

docker compose -f $dir_path/docker-compose.yml --profile db down
