#!/bin/bash
# To-do...
# Check if composer is installed and fail if it is not
# Check for a specific directory within the user's home directory – if it exists, use it, if it does not then create it

# prompts on prompts on prompts
echo "Hello, hallo, bonjour, hola, Приве́т..."
echo "
This script will attempt to perform 3 tasks: 
[1] Create a backup of the Magento 2 web root and database
[2] Use Composer to update the contents of the eBizMarts mc-magento2 package
[3] Use the Magento 2 CLI to run the setup:upgrade, setup:di:compile and cache:flush commands
"
echo "Let's get started by asking for information about the Magento 2 installation\n"
# prompt for magento2 web root
read -p "Magento 2 web root (include trailing slash): " webroot
# these arent necessary now that we're using a mysql_config_editor file
# prompt for magento 2 database name
# read -p "Magento 2 database name: " dbname
# # prompt for magento 2 database user
# read -p "Magento 2 database user: " dbuser
# # prompt for magento 2 database password but don't display it when we echo back
# read -sp "Magento 2 database password: " dbpasswd

# let's test to verify our variable assignment
# echo $webroot 
# echo $dbname 
# echo $dbuser 
# echo $dbpasswd

# create a backup of the application files, serialize it and store it in a specific directory
# tar command is tar -czf name_of_archive.tar.gz /location/to/archive/
tar -cvzf magento2-web-backup-$(date +%Y%m%d).tgz $webroot 
# create a backup of the application database(s), serialize it and store it in the same directory as the files backup
mysqldump --login-path=magento2_stage $dbname > magento2-database-backup-$(date +%Y%m%d).sql


# tar cvzf websitebackup.tgz magento2; 
# mysqldump -u user -p datase > databasebackup.sql; tar cvzf databasebackup.tgz databasebackup.sql; rm databasebackup.sql