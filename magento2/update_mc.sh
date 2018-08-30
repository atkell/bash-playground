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
echo "Let's get started by asking for information about the Magento 2 installation:"

# prompt for magento2 web root
read -p "Magento 2 web root (include trailing slash): " webroot

# create a backup of the application files, serialize it and store it in a specific directory
tar -cvzf magento2_stage-web-backup-$(date +%Y%m%d).tgz $webroot
# create a backup of the application database(s), serialize it and store it in the same directory as the files backup
mysqldump --login-path=magento2_stage magento2_stage > magento2_stage-database-backup-$(date +%Y%m%d).sql

# we need to change our working directory to the magento 2 web root or $webroot
echo "Switching the working directory to $webroot"
cd $webroot

# now we need to instruct composer to update either (a) all packages associated within the composer.json OR (b) just the mailchimp/mc-magento2 package
echo "In order to use composer, we must first change ownership to our system user. This will require sudo:"
sudo chown -R freddie:freddie /var/www/magento2 # will using sudo here prompt us for a password?

echo "Now we may use composer to update the specific package mailchimp/mc-magento2:"
composer update mailchimp/mc-magento2

echo "And now we should assign ownership of these files back to Apache user (www-data). This will require sudo:"
sudo chown -R www-data:www-data /var/www/magento2

echo "And finally, we may run a few Magento CLI commands:"
php bin/magento setup:upgrade
php bin/magento setup:di:compile
php bin/magento cache:flush

echo "Perfecto!"

