#!/bin/bash
_parent_dir () {
    path=$1
    depth=${2:-1}
    while [ $depth -ne 0 ]; do
        path=$(dirname $path)
        depth=$(($depth - 1))
    done
    echo $path
    return 0
}

dir_path=$(_parent_dir $(readlink -f $0) 2)

bash $dir_path/Administrator_Scripts/Crone_Remove.sh

bash $dir_path/Administrator_Scripts/Log.sh "Adding [0-Get_Data.py] To Crontab..."

(
	crontab -l
	# echo "* * * * * python3 $dir_path/Python_Files/0-Get_Data.py"
	# echo "* * * * * bash -c 'source $dir_path/.venv/bin/activate && python3 $dir_path/Python_Files/0-Get_Data.py' > /dev/null 2>>/home/mate/log.log"
	echo "* * * * *  $dir_path/.venv/bin/python3 $dir_path/Python_Files/0-Get_Data.py 1>>/dev/null 2>>/home/mate/log.log"
    echo "5 * * * *  $dir_path/bin/bash $dir_path/Database/Backup.sh 1>>/dev/null 2>>/dev/null"
) | crontab -
