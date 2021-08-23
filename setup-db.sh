#!/usr/bin/env bash

set -eux

# variable existence check
echo $DB
echo $CONTAINER_NAME
echo $MYSQL_HOST
echo $MYSQL_PORT
echo $MYSQL_ENDPOINT
echo $MYSQL_USERNAME
echo $MYSQL_PASSWORD

if [ "$DB" = "mysql:8.0" ]; then
    DB_EXTRA='mysqld --default-authentication-plugin=mysql_native_password'
else
    DB_EXTRA=''
fi

docker pull $DB
docker run --rm --name $CONTAINER_NAME -d \
    -p ${MYSQL_HOST}:${MYSQL_PORT}:${MYSQL_PORT} \
    -e MYSQL_ALLOW_EMPTY_PASSWORD=1 -e MYSQL_ROOT_PASSWORD='' $DB $DB_EXTRA

while ! docker container exec $CONTAINER_NAME mysql -h${MYSQL_HOST} -P${MYSQL_PORT} \
        -u${MYSQL_USERNAME} -e 'SELECT 1' &> /dev/null; do
    echo 'Waiting for MySQL...'
    sleep 1
done

docker container exec $CONTAINER_NAME mysql \
    -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USERNAME} \
    -e "INSTALL PLUGIN mysql_no_login SONAME 'mysql_no_login.so';"
