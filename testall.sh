#!/usr/bin/env bash

set -eux

export MYSQL_HOST=127.0.0.1
export MYSQL_PORT=3306
export MYSQL_ENDPOINT="${MYSQL_HOST}:${MYSQL_PORT}"
export MYSQL_USERNAME=root
export MYSQL_PASSWORD=''
export CONTAINER_NAME=terraform-provider-mysql

./setup-and-init-db.sh
trap "docker kill $CONTAINER_NAME" EXIT

make testacc
