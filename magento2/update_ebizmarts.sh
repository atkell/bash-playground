#!/bin/bash

# This script will attempt to perform 3 tasks:
# [1] Create a backup of the Magento 2 web root and database
# [2] Use Composer to update the contents of the eBizMarts mc-magento2 package
# [3] Use the Magento 2 CLI to run the setup:upgrade, setup:di:compile and cache:flush commands

whoami = $(whoami) # composer is installed for our system user so we'll need to store who we are for later
webuser = www-data # we'll set the Apache user here as a variable for later, too

# prompt for magento2 web root
read -p "Magento 2 web root (include trailing slash): " webroot

# create a backup of the application files, serialize it and store it in a specific directory
tar -cvzf magento2_stage-web-backup-$(date +%Y%m%d).tgz $webroot

# create a backup of the application database(s), serialize it and store it in the same directory as the files backup
mysqldump --login-path=magento2_stage magento2_stage > magento2_stage-database-backup-$(date +%Y%m%d).sql

# we need to change our working directory to the magento 2 web root or $webroot
cd $webroot

# in order to use composer, we must first change ownership to our system user. This will require sudo."
sudo chown -R $whoami:$whoami $webroot # doing this will prompt us for a password
composer update mailchimp/mc-magento2 # now we may use composer to update the specific package mailchimp/mc-magento2

#  aAnd finally, we may run a few Magento CLI commands
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento cache:flush

# and now we should assign ownership of these files back to Apache user (www-data). This will require sudo.
sudo chown -R $webuser:$webuser $webroot

# perfecto!

