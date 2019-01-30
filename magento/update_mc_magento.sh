#!/bin/bash
# Add some sort of help option
# if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
#   printf -- 'Some useful help message this is...\n';
#   exit 0;
# fi;

whoami="$(whoami)"

# The colors duke ... the colors!
COL_GREEN="\033[32m"
COL_YELLOW="\033[33m"
COL_RED="\033[31m"
COL_BLUE="\033[34m"
COL_CYAN="\033[96m"
COL_MAGE="\033[95m"
COL_NC="\033[0m"

# Set the paths
magento21='/var/www/magento221/'
magento22='/var/www/magento222/'
magento23='/var/www/magento223/'
magento1='/var/www/magento/'

# D R Y
upgrade_function () {
  # (1) whichPHP
  # (2) whichMagento
  # (3) whichMagentoDirectory
  # (4) whichComposerPackage

  # Salutations, user!
  printf "\n\nYou selected ${COL_YELLOW}Magento 2 v2.${whichMenuOption}${COL_NC}. If this isn't correct, use CTRL + C to Cancel.\n\n"

  # Create backups
  printf "${COL_CYAN}(Step 1)${COL_NC} Create backups of MySQL database and contents of ${whichMagentoDirectory}\n\n"
  printf "\ttar -cvzf ${whichMagento}-web-backup-$(date +%Y%m%d).tgz ${whichMagentoDirectory}"
  printf "\n\tmysqldump --login-path=${whichMagento} ${whichMagento} > ${whichMagento}-database-backup-$(date +%Y%m%d).sql"

  # Set Ownership
  printf "\n\n${COL_CYAN}(Step 2)${COL_NC} Set appropriate ownership for contents of ${whichMagentoDirectory}
  ${COL_MAGE}(Hint)${COL_NC} We're about to ask you for a password to do this.\n\n"
  # sudo chown -R $whoami:$whoami $whichMagentoDirectory
  printf "\tsudo chown -R ${whoami}:www-data ${whichMagentoDirectory}"

  # Require latest from Composer package
  printf "\n\n${COL_CYAN}(Step 3)${COL_NC} Instruct Composer to grab the latest changes to the dev-develop-2.1 branch.\n\n"
  printf "\tusr/bin/php7.1 /usr/local/bin/composer require mailchimp/mc-magento2:${whichComposerPackage}"

  # Apply new data and schema patches from update
  printf "\n\n${COL_CYAN}(Step 4)${COL_NC} Apply any new data and schema patches\n\n"
  printf "\t${whichPHP} ${whichMagentoDirectory}bin/magento setup:upgrade"

  # Compile code
  printf "\n\n${COL_CYAN}(Step 5)${COL_NC} Run the code compiler\n\n"
  printf "\t${whichPHP} ${whichMagentoDirectory}bin/magento setup:di:compile"

  # Flush cache
  printf "\n\n${COL_CYAN}(Step 6)${COL_NC} Flush the cache\n\n"
  printf "\t${whichPHP} ${whichMagentoDirectory}bin/magento cache:flush"

  # Reset ownership
  printf "\n\n${COL_CYAN}(Step 7)${COL_NC} Reset ownership for contents of ${whichMagentoDirectory}
  ${COL_MAGE}(Hint)${COL_NC} We're about to ask you for a password to do this.\n\n"
  printf "\tsudo chown -R www-data:www-data ${whichMagentoDirectory}"

  # Inform success!
  printf "\n\n${COL_GREEN}Success!${COL_NC} ${COL_YELLOW}Magento 2 v2.${whichMenuOption}${COL_NC} is now up to date."
  printf "\n"
}

upgrade_function2 () {
  printf "\n\nYou selected ${COL_YELLOW}Magento 1 v1.${whichMenuOption}${COL_NC}. If this isn't correct, use CTRL + C to Cancel.\n\n"

  # Create backups
  printf "${COL_CYAN}(Step 1)${COL_NC} Create backups of MySQL database and contents of ${whichMagentoDirectory}.\n\n"
  printf "\ttar -cvzf ${whichMagento}-web-backup-$(date +%Y%m%d).tgz ${whichMagentoDirectory}"
  printf "\n\tmysqldump --login-path=${whichMagento} ${whichMagento} > ${whichMagento}-database-backup-$(date +%Y%m%d).sql"

  # Set ownership & then change working directory
  printf "\n\n${COL_CYAN}(Step 2)${COL_NC} Set appropriate ownership for contents of ${whichMagentoDirectory}, then change our working directory.
  ${COL_MAGE}(Hint)${COL_NC} We're about to ask you for a password to do this.\n\n"
  # sudo chown -R $whoami:$whoami $whichMagentoDirectory
  printf "\tsudo chown -R ${whoami}:www-data ${whichMagentoDirectory}\n"
  printf "\tcd ${whichMagentoDirectory}mc-magento"

  # Obtain the latest from Github repository
  printf "\n\n${COL_CYAN}(Step 3)${COL_NC} Instruct git to stash local changes, then grab latest changes from branch 'develop'.\n\n"
  printf "\tgit stash --all\n"             # stash any local changes
  # printf "git fetch origin develop"    # fetch
  printf "\tgit pull origin develop"     # pull

  # Require latest from Composer package
  printf "\n\n${COL_CYAN}(Step 4)${COL_NC} Copy the contents of ${whichMagentoDirectory}mc-magento to ${whichMagentoDirectory}.\n\n"
  printf "\trsync -avz . ${whichMagentoDirectory}"

  # Apply new data and schema patches from update
  printf "\n\n${COL_CYAN}(Step 5)${COL_NC} Flush the cache.\n\n"
  printf "\trm -r ${whichMagentoDirectory}/var/cache"

  # Reset ownership
  printf "\n\n${COL_CYAN}(Step 6)${COL_NC} Reset ownership for contents of ${whichMagentoDirectory}.
  ${COL_MAGE}(Hint)${COL_NC} We're about to ask you for a password to do this.\n\n"
  printf "\tsudo chown -R www-data:www-data ${whichMagentoDirectory}"

  # Inform success!
  printf "\n\n${COL_GREEN}Success!${COL_NC} ${COL_YELLOW}Magento 1 v1.${whichMenuOption}${COL_NC} is now up to date."
  printf "\n"
}

hello_function () {
printf "\nWelcome to the ${COL_GREEN}experimental${COL_NC} upgrade system for the ${COL_YELLOW}Mailchimp for Magento 2${COL_NC} module.\n
Please note that ${COL_BLUE}we'll ask you for a password${COL_NC} during this process.
${COL_MAGE}(Hint)${COL_NC} We keep that one in ${COL_RED}LastPass${COL_NC}. \n\n"
}

hello_function
echo "Now, let's choose the number for the appropriate version of Magento to work with:"
printf "
  ${COL_YELLOW}(1)${COL_NC} Magento 2 v2.1
  ${COL_YELLOW}(2)${COL_NC} Magento 2 v2.2
  ${COL_YELLOW}(3)${COL_NC} Magento 2 v2.3
  ${COL_YELLOW}(9)${COL_NC} Magento 1 v1.9
\n"
read -n1 -p '> ' whichMenuOption
case $whichMenuOption in
  1)
    whichPHP="php7.1"
    whichMagento="magento221"
    whichMagentoDirectory=$magento21
    whichComposerPackage="dev-develop-2.1"
    upgrade_function $whichMenuOption $whichPHP $whichMagento $whichMagentoDirectory $whichComposerPackage
  ;;
  2)
    whichPHP="php7.1"
    whichMagento="magento222"
    whichMagentoDirectory=$magento22
    whichComposerPackage="dev-develop-2.2"
    upgrade_function $whichMenuOption $whichPHP $whichMagento $whichMagentoDirectory $whichComposerPackage
  ;;
  3)
    whichPHP="php"
    whichMagento="magento223"
    whichMagentoDirectory=$magento23
    whichComposerPackage="dev-develop-2.3"
    upgrade_function $whichMenuOption $whichPHP $whichMagento $whichMagentoDirectory $whichComposerPackage
  ;;
  9)
    whichMagento="magento1"
    whichMagentoDirectory=$magento1
    # whichComposerPackage="dev-develop-2.3"
    # upgrade_function $whichMenuOption $whichPHP $whichMagento $whichMagentoDirectory $whichComposerPackage
    upgrade_function2 $whichMagento $whichMagentoDirectory
  ;;
esac

# sudo chown -R freddie:www-data .;
# /usr/bin/php7.1 /usr/local/bin/composer require mailchimp/mc-magento2:dev-develop-2.1;
# php7.1 bin/magento setup:upgrade;
# php7.1 bin/magento setup:di:compile;
# php7.1 bin/magento cache:flush;
# sudo chown -R www-data:www-data .;


# A simple function that just echoes out our logo in ASCII format
# This lets users know that it is a Pi-hole, LLC product





printf -- '\n';
exit 0;
