# Parent backup directory
BACKUP_PARENT_DIR="/mnt/md1/Documents/Kodi/SauvegardeBDD/"

#MySQL Parameters
#Passwords and username will have to be stored somewhere else 
MYSQL_USER="" 
MYSQL_PASSWORD=""

#Backup Parameters
BACKUP_DATE=`date +%Y_%m_%d`
BACKUP_DIR="$BACKUP_PARENT_DIR$BACKUP_DATE"

#Create a new folder to backup files
mkdir -p ${BACKUP_DIR}

#Date management for logs
CURRENTDATE=`date +"%A %d/%m/%Y %H:%M:%S"`
REFRESH_DATE()
{
  CURRENTDATE=`date +"%A %d/%m/%Y %H:%M:%S"`
}

#Log Actions
LOGSPATH="/mnt/md1/Documents/Kodi/SauvegardeBDD/script_sauvegarde_DB_Kodi.log"

#Start writing logs
CURRENTSCRIPTNAME=`basename "$0"` #Récupération du nom du script en cours
echo "-----------------------------------------------------------------------------------------------" >> $LOGSPATH
echo "$CURRENTDATE - $CURRENTSCRIPTNAME : Script is launched. Backups are present in \"${BACKUP_DIR}\"" >> $LOGSPATH

#Purge Logs (by deleting lines older than 10 days)
#Get date to delete logs until, and convert it to the format in logs (%d/%m/%Y)
CURRENT=`date +"%s"`
NUMBEROFSECONDS=$((10 * 24 * 3600))
DATETODELETEINSEC=$(($CURRENT - $NUMBEROFSECONDS))
DATETODELETE=`date -d @$DATETODELETEINSEC +%d/%m/%Y`
#Get Line number of the last date occurence, if found
DELETEUNTILLINE=`grep -n $DATETODELETE $LOGSPATH | tail -n1 | cut -d: -f1`
#Delete all lines from first line to limit line
if [ -z "$DELETEUNTILLINE" ]; 
  then
    echo "$CURRENTDATE - $CURRENTSCRIPTNAME : No old logs to delete." >> $LOGSPATH
  else
    sed -i -e '1,'$DELETEUNTILLINE'd' $LOGSPATH
    echo "$CURRENTDATE - $CURRENTSCRIPTNAME : Deleted old logs until $DATETODELETE." >> $LOGSPATH
fi

#Remove all backups older than 10 days
cd $BACKUP_PARENT_DIR
find ./* -mtime +10 | while read line; do
  REFRESH_DATE
  echo "$CURRENTDATE - $CURRENTSCRIPTNAME : Deleting old backup '$line'" >> $LOGSPATH
  rm -rf "$line";
done

#Get MySQL databases
MYSQL_DB=`echo 'show databases' | mysql --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} -B | sed /^Database$/d`

#Backup and compress each non-system database
for DB in $MYSQL_DB
do
  if [ "${DB}" != "information_schema" ] && [ "${DB}" != "performance_schema" ] && [ "${DB}" != "mysql" ]; then
    REFRESH_DATE
    echo "$CURRENTDATE - $CURRENTSCRIPTNAME : Creating backup of \"${DB}\" database."  >> $LOGSPATH
    mysqldump --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${DB} | gzip > "${BACKUP_DIR}/${DB}.gz"
  fi
done

#Last log
echo "$CURRENTDATE - $CURRENTSCRIPTNAME : Script execution is now finished." >> $LOGSPATH
