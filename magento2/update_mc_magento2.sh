#!/bin/bash
# To-Do List:
# -- Add a conditional to first check and see if there is an update available via composer, if there is, then proceed with the script,
#    if there is not then don't execute the remainder of the script

# This script will attempt to perform 3 tasks:
# [1] Create a backup of the Magento 2 web root and database
# [2] Use Composer to update the contents of the eBizMarts mc-magento2 package
# [3] Use the Magento 2 CLI to run the setup:upgrade, setup:di:compile and cache:flush commands

# 2019-01-11: Version is now required when requiring mailchimp/mc-magento:dev-develop...
# some modification to composer command line is required to handle multiple PHP versions
# /usr/bin/php7.1 /usr/local/bin/composer require mailchimp/mc-magento2:dev-develop-2.1


whoami="$(whoami)" # composer is installed for our system user so we'll need to store who we are for later
webuser="www-data" # we'll set the Apache user here as a variable for later, too

# prompt for magento2 web root
read -p "Magento 2 web root (include trailing slash): " webroot

# create a backup of the application files, serialize it and store it in a specific directory
tar -cvzf magento2_stage-web-backup-$(date +%Y%m%d).tgz $webroot
# tar -cvzf magento2-v223-web-backup-$(date +%Y%m%d).tgz /var/www/magento223/


# create a backup of the application database(s), serialize it and store it in the same directory as the files backup
# leverage mysql's mysql_config_editor here to simply the mysqldump command some (and be somewhat more secure)
mysqldump --login-path=magento2_stage magento2_stage > magento2_stage-database-backup-$(date +%Y%m%d).sql

# we need to change our working directory to the magento 2 web root or $webroot
cd $webroot

# in order to use composer, we must first change ownership to our system user. This will require sudo."
sudo chown -R $whoami:$whoami $webroot # doing this will prompt us for a password

# this is appropriate for production
# composer -vvv update mailchimp/mc-magento2 # now we may use composer to update the specific package mailchimp/mc-magento2, added -vvv option to enable debug output

# this is appropriate for stage
sudo chown -R freddie:www-data .;
/usr/bin/php7.1 /usr/local/bin/composer require mailchimp/mc-magento2:dev-develop-2.1;
php7.1 bin/magento setup:upgrade;
php7.1 bin/magento setup:di:compile;
php7.1 bin/magento cache:flush;
sudo chown -R www-data:www-data .;

sudo chown -R freddie:www-data .;
/usr/bin/php7.1 /usr/local/bin/composer require mailchimp/mc-magento2:dev-develop-2.2;
php7.1 bin/magento setup:upgrade;
php7.1 bin/magento setup:di:compile;
php7.1 bin/magento cache:flush;
sudo chown -R www-data:www-data .;

sudo chown -R freddie:www-data .;
composer -vvv require mailchimp/mc-magento2:dev-develop-2.3;
php bin/magento setup:upgrade;
php bin/magento setup:di:compile;
php bin/magento cache:flush;
sudo chown -R www-data:www-data .;

#  aAnd finally, we may run a few Magento CLI commands
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento cache:flush

# and now we should assign ownership of these files back to Apache user (www-data). This will require sudo.
sudo chown -R $webuser:$webuser $webroot

# perfecto!
