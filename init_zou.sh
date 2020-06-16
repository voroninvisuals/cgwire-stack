#!/bin/sh

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

mkdir -p ${PREVIEW_FOLDER} ${TMP_DIR}

zou init_db
zou upgrade_db
zou init_data
zou create_admin admin@example.com --password mysecretpassword
