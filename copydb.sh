#!/bin/sh 

RUSER=backup 
RHOST=XXX.XX.XXX.XX
RDBUSER=dbbackup
RDB="$1"
RDBHOST=localhost
RBAK="/tmp/$RDB.sql"
RDBPASS="root"

LUSER=root
LPASS="root"
LHOST=localhost
LDB="$RDB"
LBAK=/tmp 

echo "Starting Backup to $RBK ..."

#dump remote db
ssh $RUSER@$RHOST "mysqldump -h $RDBHOST -u$RDBUSER -p$RDBPASS $RDB | sed -e 's/DEFINER[ ]*=[ ]*[^*]*\*/\*/' > $RBAK"

echo "Copying to Local ..." 

scp $RUSER@$RHOST:$RBAK $LBAK

echo "Importing database ... "
mysql -u$LUSER -h $LHOST -p$LPASS  -Bse "drop database if exists $LDB; create database $LDB;"
mysql -u$LUSER -h $LHOST -p$LPASS $LDB < $RBAK

