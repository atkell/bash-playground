#!/usr/bin/env bash
# magento 1 uses git, so we may use git log -1
# magento 2 uses composer, so we may use composer show mailchimp/mc-magento2
# we can refine the response using grep

locations () {
    magento21='/var/www/magento221'
    magento22='/var/www/magento222'
    magento23='/var/www/magento223'
    magento1='/var/www/magento'
}

magento21 () {
    cd $magento21
    composer_output="$(composer show mailchimp/mc-magento2 | grep 'source')"
    composer_output_commit=${composer_output:61}
    echo "Magento 2.1:" $composer_output_commit
}

magento22 () {
    cd $magento22
    composer_output="$(composer show mailchimp/mc-magento2 | grep 'source')"
    composer_output_commit=${composer_output:61}
    echo "Magento 2.1:" $composer_output_commit
}

magento23 () {
    cd $magento23
    composer_output="$(composer show mailchimp/mc-magento2 | grep 'source')"
    composer_output_commit=${composer_output:61}
    echo "Magento 2.1:" $composer_output_commit
}

# magento1 () {
#     cd $magento1
#     git_output="$(sudo git log -1 | grep 'commit')" # ownership conflict without sudo
#     return git_output
# }

get_commits() {
    printf "Hello! *waves* \nHere are the latest commits I've found...\n"
    magento21
    magento22
    magento23
    # magento1
}

get_commits
