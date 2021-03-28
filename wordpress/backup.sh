#!/bin/bash

config_file="./config"

if [ ! -f "$config_file" ]; then
	echo "you have to provide a config file"
    exit 1
fi

#read config (source)
. "$config_file"




#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
	errorecho "ERROR: This script has to be run as root!"
	exit 1
fi



#
# Stop web server
#
echo "Stopping web server..."
systemctl stop apache
echo "Done"
echo


### Backup files
echo "rsync actual version to backup dir"
rsync -avz --delete $OPTIONS $wp_dir $backup_dir/files



### Backup DB
mkdir -p $tmp_dir
mysqldump --single-transaction -h localhost -u $sql_user -p"$sql_pw" $sql_db_name > $tmp_dir/db.sql
rsync -avz --delete $OPTIONS $tmp_dir/db.sql $backup_dir/
rm -rf $tmp_dir

#
# Start web server
#
echo "Starting web server..."
systemctl start "${webserverServiceName}"
echo "Done"
echo

