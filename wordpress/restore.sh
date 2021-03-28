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


### Restore files
echo "rsync actual version to backup dir"
rsync -avz --delete $rsync_options $backup_dir/files $wp_dir
chown -R www-data:www-data $wp_dir


### Restore DB

mkdir -p $tmp_dir
rsync -avz --delete $OPTIONS $backup_dir/db.sql $tmp_dir/

mysql -h localhost -u $sql_user -p"${sql_pw}" -e "DROP DATABASE $sql_db_name"
mysql -h localhost -u $sql_user -p"${sql_pw}" -e "CREATE DATABASE $sql_db_name"

mysql -h localhost -u "${sql_user}" -p"${sql_pw}" "${sql_db_name}" < "${tmp_dir}/db.sql"

rm -rf $tmp_dir


#
# Start web server
#
echo "Starting web server..."
systemctl start "${webserverServiceName}"
echo "Done"
echo

