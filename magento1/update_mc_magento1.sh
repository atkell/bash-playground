#!/bin/bash
# To-Do List:
# -- Add a conditional to first check and see if there is an update available via git, if there is, then proceed with the script, 
#    if there is not then don't execute the remainder of the script

# This script will attempt to perform 3 tasks:
# [1] Create a backup of the Magento 1 web root and database
# [2] Use git to update the contents of the mc-magento directory and then copy said contents to the Magento 1 web root
# [3] Use the command line to manually flush the Magento 1 cache

# get the user who is currently authenticated in shell session
whoami="$(whoami)"

# we'll set the Apache user here as a variable for later, too
webuser="www-data"

# prompt for magento 1 web root and assign the input to the variable webroot
read -p "Magento 1 web root (include trailing slash): " webroot

# create a backup of the application files, serialize it and store it in a specific directory
tar -cvzf magento1_stage-web-backup-$(date +%Y%m%d).tgz $webroot 

# leverage mysql's mysql_config_editor here to simplify the mysqldump command some (and be somewhat more secure by not exposing the password in plain-text), 
# create a backup of the application database(s), serialize it and store it in the same directory as the files backup.
# we create the login path with the following command: mysql_config_editor set --login-path=your_name --host=your_host --user=your_user --password
# this will prompt you to input a password and then save it all into the .mylogin.cnf file within the user's home directory
mysqldump --login-path=magento1_stage magento_stage > magento1_stage-database-backup-$(date +%Y%m%d).sql 

# we need to change our working directory to the magento 1 web root 
#cd $webroot # this probably isnt necessary anymore

# we may need to elevate and run some commands 
sudo chown -R $whoami:$whoami $webroot

# change working directory to mc-magento sub-direction within $webroot
cd $webroot/mc-magento 

# use git to pull down latest changes from upstream repository
git pull origin develop

 # copy the contents of the mc-magento directory back into the magento 1 web root
cp -R . $webroot

# flush the magento 1 cache. we could also simply do rm -rf var/cache here instead but this seems more appropriate
php -r 'require "app/Mage.php"; Mage::app()->getCacheInstance()->flush();' 

sudo chown -R $webuser:$webuser $webroot # and now we should assign ownership of these files back to Apache user (www-data). This will require sudo.

# perfecto!

