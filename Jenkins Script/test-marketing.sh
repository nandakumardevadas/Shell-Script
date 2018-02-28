#!/bin/bash
cd $WORKSPACE
echo "================================ Started To deploy ================================="
echo $BUILD_TAG;
echo "====================================================================================="

### configurations 
echo "======= Selected branch name : " $Branch_Name " (user selected) =================="


BRANCH_NAME=$Branch_Name
#BRANCH_NAME='master'

echo "======= Selected branch name : " $BRANCH_NAME " =================="

ENV_FILE=".env"

#check the project already exist
echo "================== checking project - Marketing folder is already exist ============="
if [ ! -d "marketing" ]; then
	echo "====================== No , Not exist ========================="
    echo "================== Creating Marketing folder ==============="
	mkdir marketing
    cd marketing/
    
    git clone git@icms.ihorsetechnologies.com:doopaadoo/dpd-marketing.git .
    
else
  echo "========================= Yes, exist ========================"
  echo "=================== Moving to Marketing Folder ==================="
  cd marketing/
  
fi

echo "################## git fetch ##################"
git fetch 

echo "=================== checkour" $BRANCH_NAME " branch  ==================="

git checkout $BRANCH_NAME


echo "################## git pull ##################"

git pull 

echo "################## composer install ##################"
composer install

#clear composer cache
echo "################## composer dump-autoload ##################"
composer dump-autoload

echo "################## composer artisan optimize ##################"
php artisan optimize

echo "################## check .env exist ##################"

if [ -f "$ENV_FILE" ]
then
	echo "$ENV_FILE Already Exist."
	echo "delete the Old $ENV_FILE file."
	rm -f .env
else
	echo "$ENV_FILE was not found."
fi

echo "################## Moving test marketing .env from s3 to local ##################"
s3cmd get --recursive s3://jenkins-ipaadal/env/test/marketing/


echo "=================== Moving to workspave ==================="
cd $WORKSPACE


echo "=================== R sync the Marketing Project ==================="
rsync -rav --exclude=".git" ./ root@test-marketing.doopaadoo.com:/var/www/html/
ssh root@test-marketing.doopaadoo.com chmod -R 777 /var/www/html/marketing


echo "################## DB migreation on dev ##################" 
ssh root@test-marketing.doopaadoo.com php /var/www/html/marketing/artisan migrate

