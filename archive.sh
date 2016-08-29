DBUSER=root
DBPASS=root
DBHOST=localhost
DBNAME="local_db"
ARCHIVEPREFIX="archive_"
BACKUP="/tmp/$DBNAME.sql"
IGNTABLES=(master_1 master_2)

TABLES=$(mysql -h $DBHOST -u$DBUSER -p$DBPASS $DBNAME  -e 'show tables' | awk '{ print $1}' | grep -v '^Tables' )

#make sure tables exits
if [ "$TABLES" == "" ]
then
	echo "No table found in $DBNAME database!"
	exit 3
fi

#copy live DB to archive DB
echo "Dumping $DBNAME"
mysqldump -h $DBHOST -u$DBUSER  -p$DBPASS "$DBNAME" | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' > $BACKUP
echo "Created dump for $DBNAME"

mysql -u$DBUSER -h $DBHOST -p$DBPASS  -Bse "drop database if exists $ARCHIVEPREFIX$DBNAME; create database $ARCHIVEPREFIX$DBNAME;"
echo "Restoring to $ARCHIVEPREFIX$DBNAME"
mysql -u$DBUSER -h $DBHOST -p$DBPASS $ARCHIVEPREFIX$DBNAME < "$BACKUP"
echo "Restored to $ARCHIVEPREFIX$DBNAME"

#remove data from live tables 
#DO NOT TRUNCATE BECAUSE IT FLUSH AUTOINCREMENT KEYS
for t in $TABLES
do
	if echo ${IGNTABLES[@]} | grep -q -w "$t"; then
	continue
	fi

	echo "Deleting $t table from $DBNAME database..."
	mysql --host=$DBHOST -u $DBUSER -p$DBPASS "$DBNAME" -e "DELETE FROM $t"
done
