#!/bin/bash

SAVE_PATH='/var/www/dbbackup/'
PASS=root
HOST=localhost

# also backup all_clubs , common_db, information_schema  and mysql db
dbs=(mysql information_schema)

for db in ${dbs[*]}
do
	echo "Dumping $db"
	mysqldump --host=$HOST -u "root" -p$PASS --single-transaction --opt $db | gzip >  $SAVE_PATH/$db.$(date +%Y%m%d).sql.gz
done

cd $SAVE_PATH

tar -cf dbbackup.$(date +%Y%m%d).tar *.$(date +%Y%m%d).sql.gz

if [ $? -eq 0 ]; then
    rm *.$(date +%Y%m%d).sql.gz
fi
