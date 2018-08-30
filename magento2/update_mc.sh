#!/bin/bash
# To-do...
# Check if composer is installed and fail if it is not
# Check for a specific directory within the user's home directory – if it exists, use it, if it does not then create it

# prompts on prompts on prompts
echo "Hello, hallo, bonjour, hola, Приве́т..."
echo "
This script will attempt to perform 3 tasks:
[1] WIP: Create a backup of the Magento 2 web root and database
[2] To-do: Use Composer to update the contents of the eBizMarts mc-magento2 package
[3] To-do: Use the Magento 2 CLI to run the setup:upgrade, setup:di:compile and cache:flush commands
"
echo "Let's get started by asking for information about the Magento 2 installation\n"

# prompt for magento2 web root
read -p "Magento 2 web root (include trailing slash): " webroot

# create a backup of the application files, serialize it and store it in a specific directory
tar -cvzf magento2_stage-web-backup-$(date +%Y%m%d).tgz $webroot
# create a backup of the application database(s), serialize it and store it in the same directory as the files backup
mysqldump --login-path=magento2_stage magento2_stage > magento2_stage-database-backup-$(date +%Y%m%d).sql
