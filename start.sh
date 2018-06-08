#!/bin/bash

# prepare data directory
mkdir -p /app/data/build && \
mkdir -p /app/data/uploads
chown -R cloudron:cloudron /app/data

if [ -f .sequelizerc ];
then
    node_modules/.bin/sequelize db:migrate
fi

# wait for db up
sleep 3

export NODE_ENV='production'
export HMD_DB_URL="$POSTGRESQL_URL"
export HMD_LDAP_URL="$LDAP_URL"
export HMD_LDAP_BINDDN="$LDAP_BIND_DN"
export HMD_LDAP_BINDCREDENTIALS="$LDAP_BIND_PASSWORD"
export HMD_LDAP_SEARCHBASE="$LDAP_USERS_BASE_DN"
export HMD_LDAP_SEARCHFILTER="(username={{username}})"
export HMD_LDAP_USERNAMEFIELD="username"
export HMD_IMAGE_UPLOAD_TYPE=filesystem
# access default permissions setting 
export HMD_ALLOW_ANONYMOUS=false
export HMD_ALLOW_ANONYMOUS_EDITS=true
export HMD_ALLOW_FREEURL=false
export HMD_DEFAULT_PERMISSION="limited"
# the following two changes could be transferred to config.json to enable users to change this
export HMD_EMAIL=false
export HMD_ALLOW_EMAIL_REGISTER=false
# disable pdf export until https://github.com/hackmdio/hackmd/issues/820 is fixed
export HMD_ALLOW_PDF_EXPORT=false
# respect users privacy and make notes private by default
export HMD_DEFAULT_PERMISSION=private

# run
/usr/local/bin/gosu cloudron:cloudron node app.js
