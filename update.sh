#! /bin/bash

issuenr=''
package='drupal'

print_usage() {
  printf "Usage: \n Issuenr (Needed for commit message): -i SPY-1688 \n Package (drupal by default): -p cweagans/composer-patches"
}

while getopts 'i:p:' flag; do
  case "${flag}" in
    i) issuenr="${OPTARG}" ;;
    p) package=${OPTARG} ;;
    *) print_usage
       exit 1 ;;
  esac
done

if [ "$package" == 'drupal' ]; then
  echo 'What drupal module are you updating? ( use the -p flag to update a non drupal package)'
  read -r modulename
  package="drupal/$modulename"
fi

echo '==============================================='
echo "running composer update $package -o --ignore-platform-reqs"
echo '==============================================='
composer update "$package" -o --ignore-platform-reqs

echo '==============================================='
echo 'Cleaning files that should not be changed.'
echo '==============================================='
git checkout .htaccess .eslintrc.json sites/development.services.yml sites/example.settings.local.php .gitattributes sites/development.services.yml

echo '==============================================='
echo 'git status and diff to composer lock'
echo '==============================================='
git status

git diff composer.lock

git diff composer.lock | grep version

while true; do
    read -r -p "Add files to git? [y/n] " yn
    case $yn in
        [Yy]* ) git add *; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "What version was the module?"
read -r oldversion

echo "What version is the module now?"
read -r newversion

echo '==============================================='
git branch --show-current
echo '==============================================='

if [ "$issuenr" == '' ]; then
  echo 'What issue are you working on? example: SPY-1688'
  read -r issuenr
fi

git commit -m "[SUPPORT] #$issuenr update $package from $oldversion to $newversion using composer update $package -o --ignore-platform-reqs" --no-verify
