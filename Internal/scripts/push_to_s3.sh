#!/bin/bash
read -s -p "Enter Password: " scriptpassword

if [ "$scriptpassword" != "S3PUSH!@#." ]; then
    printf "\n Access denied. Please check the access permissions!!! \n"
    exit
fi

echo
# Folder Path - DONT SLASH AT THE END
PATH_APP_DEV="/home/nandakumar/Documents/doopaadoo-server/server-env/env/dev/live"
PATH_PREVIEW_DEV="/home/nandakumar/Documents/doopaadoo-server/server-env/env/dev/preview"

PATH_APP_TEST="/home/nandakumar/Documents/doopaadoo-server/server-env/env/test/live"
PATH_PREVIEW_TEST="/home/nandakumar/Documents/doopaadoo-server/server-env/env/test/preview"

PATH_APP_STAGE="/home/nandakumar/Documents/doopaadoo-server/server-env/env_stag/web /home/nandakumar/Documents/doopaadoo-server/server-env/env_stag/api"
PATH_PREVIEW_STAGE="/home/nandakumar/Documents/doopaadoo-server/server-env/env_stag/preview"

PATH_APP_PROD="/home/nandakumar/Documents/doopaadoo-server/server-env/env_live /home/nandakumar/Documents/doopaadoo-server/server-env/env_api"
# PATH_PREVIEW_PROD="/home/nandakumar/Documents/doopaadoo-server/server-env/env/test/preview"

PATH_BACKOFFICE_DEV="/home/nandakumar/Documents/doopaadoo-server/server-env/env/dev/backoffice"
PATH_BACKOFFICE_TEST="/home/nandakumar/Documents/doopaadoo-server/server-env/env/test/backoffice"
# PATH_BACKOFFICE_STAGE="/home/nandakumar/Documents/doopaadoo-server/server-env/env/test/live"
# PATH_BACKOFFICE_PROD="/home/nandakumar/Documents/doopaadoo-server/server-env/env/test/live"

PATH_MARKETINGBO_DEV="/home/nandakumar/Documents/doopaadoo-server/server-env/env/dev/marketing"
PATH_MARKETINGBO_TEST="/home/nandakumar/Documents/doopaadoo-server/server-env/env/test/marketing"
PATH_MARKETINGBO_STAGE="/home/nandakumar/Documents/doopaadoo-server/server-env/env/stag/marketing"
PATH_MARKETINGBO_PROD="/home/nandakumar/Documents/doopaadoo-server/server-env/env/prod/marketing"

# S3 Path - DONT SLASH AT THE START AND END
S3PATH_APP_DEV="env/dev/live"
S3PATH_PREVIEW_DEV="env/dev/preview"

S3PATH_APP_TEST="env/test/live"
S3PATH_PREVIEW_TEST="env/test/preview"

S3PATH_APP_STAGE="env_stag"
S3PATH_PREVIEW_STAGE="env_stag/preview"

S3PATH_BACKOFFICE_DEV="env/dev/backoffice"
S3PATH_BACKOFFICE_TEST="env/test/backoffice"
# S3PATH_BACKOFFICE_STAGE="/home/nandakumar/Documents/doopaadoo-server/server-env/env/test/live"
# S3PATH_BACKOFFICE_PROD="/home/nandakumar/Documents/doopaadoo-server/server-env/env/test/live"

S3PATH_MARKETINGBO_DEV="env/dev/marketing"
S3PATH_MARKETINGBO_TEST="env/test/marketing"
S3PATH_MARKETINGBO_STAGE="env/staging/marketing"
S3PATH_MARKETINGBO_PROD="env/production/marketing"


# To Get Last Directory name
function getLastDirectoryName {
   dir="$(dirname $1)"
   __="$(basename $dir)"
}

function downloadFromS3 {
    if($BACKUP == "true"); then
        printf "${YELLOW} Backing up the file... ${NC}\n"
        s3cmd get s3://jenkins-ipaadal/$1/.env $BACKUPPATH/$2/$1/env
    fi
}

function uploadToS3 {
    printf "${YELLOW} Uploading the file... ${NC}\n"
    s3cmd put $1 s3://jenkins-ipaadal/$2/.env
}

# declare -a environmentArray=("DEV" "TEST" "STAGE" "PROD")
declare -a environmentArray=("DEV" "TEST" "STAGE" "ALL")
declare -a typeArray=("APPLICATION" "BACKOFFICE" "MARKETING-BACKOFFICE")

TITLE="Push Environmental Variable to S3 - ONLY TO DEV, TEST, STAGE NOT TO PRODUCTION" 

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
DATE=`date +%Y-%m-%d:%H:%M:%S`
BACKUPDATE=`date +%Y%m%d%H%M%S`
BACKUP=true
BACKUPPATH="/home/nandakumar/Documents/Doopaadoo/env-backup"
printf "${ORANGE}$TITLE${NC}\n"

if [ -z $1 ]; then
    printf "\n${CYAN}Backup Enabled !!!${NC}\n"
else
    BACKUP=false
    printf "\n${CYAN}Backup Disabled !!!${NC}\n"
fi

PS3='Please enter your choice: '
echo
select TYPE in ${typeArray[@]}
do
   case $TYPE in
      APPLICATION) 
         printf "\n ${CYAN} WEB and API is selected ${NC}\n"
         declare -a typeInfoArray=("APP" "PREVIEW")
         break
         ;;
      BACKOFFICE)
         printf "\n ${CYAN} BACKOFFICE is selected ${NC}\n"
         declare -a typeInfoArray=("BACKOFFICE")
         break
      ;;
      MARKETING-BACKOFFICE) 
        printf "\n ${CYAN} MARKETING BACKOFFICE is selected ${NC}\n"
        declare -a typeInfoArray=("MARKETINGBO")
        break 
      ;;
      *)  printf "\n ${RED} Invalid Selection !!! ${NC}\n"
      ;;
   esac
done
echo

PS3='Please enter the environment: '
echo
select ENVIRONMENT in ${environmentArray[@]}
do
   case $ENVIRONMENT in
      DEV) 
         printf "\n ${CYAN} DEV ENVIRONMENT is selected ${NC}\n"
         declare -a environmentArray=("DEV")
         break
         ;;
      TEST)
         printf "\n ${CYAN} TEST ENVIRONMENT is selected ${NC}\n"
         declare -a environmentArray=("TEST")
         break
      ;;
      STAGE) 
        printf "\n ${CYAN} STAGE ENVIRONMENT is selected ${NC}\n"
        declare -a environmentArray=("STAGE")
        break 
      ;;
      ALL) 
        printf "\n ${CYAN} DEV, TEST, STAGE ENVIRONMENT is selected ${NC}\n"
        declare -a environmentArray=("DEV" "TEST" "STAGE")
        break
      ;;
      *)  printf "\n ${RED} Invalid Selection !!! ${NC}\n"
      ;;
   esac
done
echo

if($BACKUP == "true"); then
        echo $BACKUPDATE'======='$TYPE'===='$ENVIRONMENT'=====' >> $BACKUPPATH/log.txt
fi

for i in "${environmentArray[@]}"
do
    echo
    printf "============${YELLOW}"$i"${NC}============ \n"
    echo "===========Started in $i============"
    for TYPEINFO in "${typeInfoArray[@]}"
    do
        eval temp="\$PATH_"$TYPEINFO"_"$i
        eval s3temp="\$S3PATH_"$TYPEINFO"_"$i
        echo
        FINDCOUNT=$(find $temp -type f -name "env" | wc -l)
        if [ $FINDCOUNT -ne 0 ]; then
            find $temp -type f -name "env" | while read file; do
            if [ -f "$file" ]
                then
                    if [ -z $s3temp ]; then
                        echo
                         printf "${RED} S3PATH Variable not found for $file!!!!!! ${NC} \n"
                        echo
                    else
                        getLastDirectoryName $file
                        S3UPLOADEDPATH=$s3temp
                        if [ "$__" == "web" ] || [ "$__" == "api" ]; then
                            S3UPLOADEDPATH=$s3temp/$__
                        fi

                        downloadFromS3 $S3UPLOADEDPATH $BACKUPDATE
                        uploadToS3 $file $S3UPLOADEDPATH
                            
                        echo
                        printf "Updated Value From ${GREEN}$file ${NC}to ${GREEN}$S3UPLOADEDPATH ${NC}\n"
                        echo
                    fi
                else
                    printf "${RED} $file not found.!!! ${NC}\n"
                fi
            done
            echo
        else 
            printf "${RED} No Path provided for $TYPEINFO!!! ${NC}\n"
        fi
    done
    echo
    echo "===========Completed in $i============"
    echo
done

