#!/bin/bash

SAVE_PATH='/var/www/dbbackup/'
PASS=root
HOST=localhost

ALLDBS=($(mysql --host=$HOST -u "root" -p$PASS << END
show databases;
END))

for dbname in "${ALLDBS[@]}"

do    

    if [[ "$dbname" == "Database" ]]; then
	continue
    fi

    DB="$dbname"    
    echo "Dumping for $dbname"		
    mysqldump --host=$HOST -u "root" --single-transaction -p$PASS --opt "$DB" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' | gzip > $SAVE_PATH/"$dbname".$(date +%Y%m%d).sql.gz

done

cd $SAVE_PATH

tar -cf dbbackup.$(date +%Y%m%d).tar *.$(date +%Y%m%d).sql.gz

if [ $? -eq 0 ]; then
    rm *.$(date +%Y%m%d).sql.gz
fi
