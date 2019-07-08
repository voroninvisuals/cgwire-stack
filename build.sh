#!/usr/bin/env bash

CYAN="\e[1;36m"
BLUE="\e[1;34m"
LYELLOW="\e[1;93m"
LGREEN="\e[1;92m"
DEFAULT="\e[0;0;0m"

INIT=0
BUILD=0
ENV_FILE=./env

echo "${LGREEN}GET ARGS${DEFAULT}"
for i in "$@"
do
case $i in
    -i | --init)
    INIT=1
    echo -e "${CYAN}INIT MODE ACTIVATED${DEFAULT}"
    shift
    ;;
    -b | --build)
    BUILD=1
    echo "${CYAN}USE LOCAL BUILD${DEFAULT}"
    shift
    ;;
    -e=* | --env=*)
    ENV_FILE="${i#*=}"
    echo "${CYAN}CUSTOM ENV FILE${DEFAULT}"
    shift
    ;;
    *)
          # unknown option
    ;;
esac
done

echo -e "${LGREEN}SOURCE ENV${DEFAULT}"
source ${ENV_FILE}
ENV=$(cat ${ENV_FILE})


echo -e "${LYELLOW}STOP OLD CONTAINER${DEFAULT}"
docker-compose down

if [ $BUILD == 1 ]; then
    echo -e "${BLUE}BUILD CONTAINER${DEFAULT}"
    env ${ENV} docker-compose build --force-rm --pull --compress

    echo -e "${LYELLOW}START NEW CONTAINER${DEFAULT}"
    env ${ENV} docker-compose -f docker-compose-build.yml up -d
else
    echo -e "${LYELLOW}START NEW CONTAINER${DEFAULT}"
    env ${ENV} docker-compose up -d
fi


if [ $INIT == 1 ]; then
    echo -e "${LGREEN}INIT ZOU${DEFAULT}"
    docker-compose exec db su - postgres -c "createuser root"
    docker-compose exec db su - postgres -c "createdb -T template0 -E UTF8 --owner root root"
    docker-compose exec db  su - postgres -c "createdb -T template0 -E UTF8 --owner root zoudb"
    docker-compose exec zou-app sh init_zou.sh
else
    echo -e "${LGREEN}UPGRADE ZOU${DEFAULT}"
    docker-compose exec zou-app sh upgrade_zou.sh
fi