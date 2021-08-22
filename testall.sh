#!/usr/bin/env bash

set -eux

echo $DB
echo $DB_EXTRA

make test
make vet
export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_USERNAME=root
export MYSQL_ENDPOINT="${MYSQL_HOST}:${MYSQL_PORT}"
export MYSQL_PASSWORD=''
docker pull $DB
container_id=$(docker run --rm -d -p ${MYSQL_HOST}:${MYSQL_PORT}:${MYSQL_PORT} -e MYSQL_ALLOW_EMPTY_PASSWORD=1 -e MYSQL_ROOT_PASSWORD='' $DB $DB_EXTRA)
trap "docker kill $container_id" EXIT

while ! mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USERNAME} -e 'SELECT 1'; do
    echo 'Waiting for MySQL...'
    sleep 1;
done;
mysql -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USERNAME} -e "INSTALL PLUGIN mysql_no_login SONAME 'mysql_no_login.so';"
make testacc
