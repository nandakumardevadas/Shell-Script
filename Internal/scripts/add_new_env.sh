#!/bin/bash

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

declare -a environmentArray=("DEV" "TEST" "STAGE" "PROD")
declare -a typeArray=("APPLICATION" "BACKOFFICE" "MARKETING-BACKOFFICE")

TITLE="Environmental Variable Maintanance" 

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
ORANGE='\033[0;33m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
DATE=`date +%Y-%m-%d:%H:%M:%S`

printf "${ORANGE}$TITLE${NC}\n"

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
read -p "Enter new Env name: " envName
read -p "Enter new Env value: " envValue

if [ -z "$envName" ]; then
   printf "${RED}Please enter env name\n"
   exit 1
elif [ -z "$envValue" ]; then
   printf "${RED}Please enter env value\n"
   exit 1
fi

for i in "${environmentArray[@]}"
do
    echo
    printf "============${YELLOW}"$i"${NC}============ \n"
    echo
    read -e -i "$envValue" -p "Enter new value to override default value in this environment: " newValue
    echo
    value=${newValue:-$envValue}
    echo "===========Started in $i============"
    for TYPEINFO in "${typeInfoArray[@]}"
    do
        eval temp="\$PATH_"$TYPEINFO"_"$i
        echo
        FINDCOUNT=$(find $temp -type f -name "env" | wc -l)
        if [ $FINDCOUNT -ne 0 ]; then
            find $temp -type f -name "env" | while read file; do
            if [ -f "$file" ]
                then
                    # grep -q $envName $file && echo "****** ENV ALREADY EXISTS in $file ****** $envName=$value echo" || echo "$envName=$value" >> $file echo "Updated Value =====> $envName=$value"
                    if grep -q $envName $file; then 
                        printf "${RED}ENV Variable ALREADY EXISTS in $file. Please edit manually ${NC}=====> ${ORANGE}$envName=$value ${NC}\n"
                    else
                        # echo "#$DATE" >> $file
                        sed -i -e '$a'$envName'='$value $file
                        # echo "$envName=$value" >> $file
                        echo
                        printf "Updated Value in ${GREEN}$file${NC} =====> ${ORANGE}$envName=$value ${NC}\n"
                    fi
                    echo
                else
                    printf "${RED} $file not found.!!! ${NC}\n"
                fi
            done
            # find $temp -type f -exec \
            #     sed -i -e '$a'$envName'='$value {} + 
            echo
        else 
            printf "${RED} No Path provided for $TYPEINFO!!! ${NC}\n"
        fi
    done
    echo
    echo "===========Completed in $i============"
    echo
done
