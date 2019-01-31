#!/usr/bin/env bash

main () {
  # Set the paths
  magento21='/var/www/magento221'
  magento22='/var/www/magento222'
  magento23='/var/www/magento223'
  magento1='/var/www/magento'
  whoami="$(whoami)"
  # The colors duke ... the colors!
  COL_GREEN="\033[32m"
  COL_YELLOW="\033[33m"
  COL_RED="\033[31m"
  COL_BLUE="\033[34m"
  COL_CYAN="\033[96m"
  COL_MAGE="\033[95m"
  COL_NC="\033[0m"
  check_for_updates
  # hello_function
}

check_for_updates () {
  printf "Let's do a quick check to see if this update script is up-to-date.\n"
  cd ~/scripts
  git fetch -q origin
  hello_function

  # 2019-01-31: not working correctly
  # if [[ $(git status --porcelain) ]]; then
  #   printf "Looks like there were changes upstream. Let's try to apply those."
  #   git pull -q origin master
  #   exec ~/scripts/magento/update_mc_magento.sh
  # else
  #   printf "${COL_GREEN}Everything was up to date, yay!${COL_NC}\n\n"
  #   hello_function
  # fi
}

upgrade_function () {
  printf "\n\nYou selected ${COL_YELLOW}Magento 2 v2.${whichMenuOption}${COL_NC}. Shall we proceed with the update?\n"
  printf "Type ${COL_GREEN}Y${COL_NC} for ${COL_GREEN}Yes${COL_NC}, ${COL_RED}N${COL_NC} for ${COL_RED}No${COL_NC}. "
  read -n1 -p '> ' confirmation
  case $confirmation in
    y|Y)
      cd ~/backups
      printf "\n\n${COL_CYAN}(Step 1)${COL_NC} Set appropriate ownership for contents of ${whichMagentoDirectory}\n"
      printf "${COL_MAGE}(Hint)${COL_NC} We're may ask you for a password to do this.\n\n"
      sudo chown -R $whoami:www-data $whichMagentoDirectory

      printf "\n\n${COL_CYAN}(Step 2)${COL_NC} Create backups of MySQL database and contents of ${whichMagentoDirectory}\n\n"
      tar -czf $whichMagento-web-backup-$(date +%Y%m%d).tgz $whichMagentoDirectory
      mysqldump --login-path=$whichMagento $whichMagento > $whichMagento-database-backup-$(date +%Y%m%d).sql

      printf "\n\n${COL_CYAN}(Step 3)${COL_NC} Instruct Composer to grab the latest changes to the branch ${whichComposerPackage}.\n\n"
      # composerRequire="/usr/local/bin/composer require mailchimp/mc-magento2:$whichComposerPackage"
      # $whichPHP $composerRequire
      cd $whichMagentoDirectory
      echo $(pwd)
      $whichPHP /usr/local/bin/composer require mailchimp/mc-magento2:$whichComposerPackage

      printf "\n\n${COL_CYAN}(Step 4)${COL_NC} Apply any new data and schema patches\n\n"
      $whichPHP $whichMagentoDirectory/bin/magento setup:upgrade

      printf "\n\n${COL_CYAN}(Step 5)${COL_NC} Run the code compiler\n\n"
      $whichPHP $whichMagentoDirectory/bin/magento setup:di:compile

      printf "\n\n${COL_CYAN}(Step 6)${COL_NC} Flush the cache\n\n"
      $whichPHP $whichMagentoDirectory/bin/magento cache:flush

      printf "\n\n${COL_CYAN}(Step 7)${COL_NC} Reset ownership for contents of ${whichMagentoDirectory}\n"
      printf "${COL_MAGE}(Hint)${COL_NC} We're may to ask you for a password to do this.\n\n"
      sudo chown -R www-data:www-data $whichMagentoDirectory

      printf "\n\n${COL_GREEN}Success!${COL_NC} ${COL_YELLOW}Magento 2 v2.${whichMenuOption}${COL_NC} is now up to date."
      printf "\n"
    ;;
    n|N) hello_function ;;
    *) printf "\n\nHmm, I'm sorry, I don't understand that option. Try again?\n"
       hello_function ;;
  esac
}

upgrade_function2 () {
  printf "\n\nYou selected ${COL_YELLOW}Magento 1 v1.${whichMenuOption}${COL_NC}. If this isn't correct, use CTRL + C to Cancel.\n\n"
  printf "Shall we proceed with update? Type ${COL_GREEN}Y${COL_NC} for ${COL_GREEN}Yes${COL_NC}, ${COL_RED}N${COL_NC} for ${COL_RED}No${COL_NC}.\t"
  read -n1 -p '> ' confirmation
  case $confirmation in
    y|Y)
      cd ~/backups
      printf "\n\n${COL_CYAN}(Step 1)${COL_NC} Set appropriate ownership for contents of ${whichMagentoDirectory}\n"
      printf "${COL_MAGE}(Hint)${COL_NC} We're may ask you for a password to do this.\n\n"
      sudo chown -R $whoami:www-data $whichMagentoDirectory

      printf "\n\n${COL_CYAN}(Step 2)${COL_NC} Create backups of MySQL database and contents of ${whichMagentoDirectory}.\n\n"
      tar -czf $whichMagento-web-backup-$(date +%Y%m%d).tgz $whichMagentoDirectory
      mysqldump --login-path=$whichMagento $whichMagento > $whichMagento-database-backup-$(date +%Y%m%d).sql
      cd $whichMagentoDirectory/mc-magento

      printf "\n\n${COL_CYAN}(Step 3)${COL_NC} Instruct git to stash local changes, then grab latest changes from branch 'develop'.\n\n"
      git stash --all
      git fetch origin develop
      git pull origin develop

      printf "\n\n${COL_CYAN}(Step 4)${COL_NC} Copy the contents of ${whichMagentoDirectory}mc-magento to ${whichMagentoDirectory}.\n\n"
      rsync -avz $whichMagentoDirectory/mc-magento/* $whichMagentoDirectory

      printf "\n\n${COL_CYAN}(Step 5)${COL_NC} Flush the cache.\n\n"
      rm -r $whichMagentoDirectory/var/cache

      printf "\n\n${COL_CYAN}(Step 6)${COL_NC} Reset ownership for contents of ${whichMagentoDirectory}.
      ${COL_MAGE}(Hint)${COL_NC} We're may ask you for a password to do this.\n\n"
      sudo chown -R www-data:www-data $whichMagentoDirectory

      printf "\n\n${COL_GREEN}Success!${COL_NC} ${COL_YELLOW}Magento 1 v1.${whichMenuOption}${COL_NC} is now up to date."
      printf "\n"
      ;;
    n|N) hello_function ;;
    *) printf "\n\nHmm, I'm sorry, I don't understand that option. Try again?\n"
      hello_function ;;
esac
}

choice_function () {
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
    *) hello_function ;;
  esac
}

hello_function () {
  printf "\nWelcome to the ${COL_GREEN}experimental${COL_NC} upgrade system for the ${COL_YELLOW}Mailchimp for Magento${COL_NC} module!\n"
  printf "Please note that ${COL_BLUE}we'll ask you for a password${COL_NC} during this process.\n"
  printf "${COL_MAGE}(Hint)${COL_NC} We keep that one in ${COL_RED}LastPass${COL_NC}. \n\n"
  choice_function
}

main

printf -- '\n';
exit 0;
