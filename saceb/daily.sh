#! /bin/bash
## pulls remote snapshot once per day
## may be called more often without concequence
## authur JR Peterson
## date 2010-01-22

forhost="sace"
#forhost="138.253.8.20"
archdirbase="/archive/${forhost}_daily"
lockfile="${archdirbase}/lock.lock"
curbackup="${archdirbase}/latest"

##### uncomment for first run to create dummy reference:
#mkdir -p ${curbackup}
#exit 



## send email procedure

email ()
{
	logitem "email called with: $1"
}

##  end of send email procedure

## start of log item 
	# this is for logging details for debugging
logitem ()
{
	echo "$1"
	echo "`date '+%Y-%m-%d.%H%M-%S'` -- $1" >> "$mainlog"
}
	# this is for checking details of what happened
daylogitem ()
{
	echo "$1"
	echo "`date '+%Y-%m-%d.%H%M-%S'` -- $1" >> "$daylog"
}
	# this is for extreme summery data
summerylogitem ()
{
	echo "$1"
	echo "`date '+%Y-%m-%d.%H%M-%S'` -- $1" >> "$summerylog"
}

## end of log item


#setup logging
dt=`date '+%Y-%m-%d.%H%M-%S'`
day=`date '+%Y-%m-%d'`

mkdir -p "/var/log/backup/daily_${forhost}/"

mainlog="/var/log/backup/daily_${forhost}/${dt}.log"
daylog="/var/log/backup/daily_${forhost}/${day}.log"
summerylog="/var/log/backup/backup.log"


logitem "daily remote backup of ${forhost} started"
daylogitem "daily remote backup of ${forhost} started"

#locate symlink to latest backup else send error email and do a first backup
### needs work

logitem "basing backup on old backup in symlink $curbackup"

#check and then create lock file
if [ -f "${lockfile}" ] 
then 
	logitem "daily remote backup failed -- lock file already exists -- aborting"
	logitem "lock file is: ${lockfile}"
	daylogitem "daily romote backup failed -- lock file already exists -- aborting"
	daylogitem "lock file is: ${lockfile}"
	summerylogitem "daily remote backup failed -- lock file already exists -- aborting"
	exit 5
fi

touch $lockfile

logitem "lock file created"


#if first backup of day record this fact in variable daily
#if [ -f  "/archive/hourly/bak${day}*" ]
#then
#	logitem "is not first backup of day"
#	daily=0
#else
#	logitem "is first backup of day"
#	daily=1
#fi

#run backup thinning -- but only of backup being done for future upgradability


#create new folder

newbackup="${archdirbase}/bak${dt}"

mkdir $newbackup > >(tee -a $mainlog) 2> >(tee -a $mainlog |tee -a $daylog >&2)

logitem "new backup directory created at..."
logitem "$newbackup"

#copy as link from last backup to new backup

logitem "starting copy ####################"


cp -al ${curbackup}/* ${newbackup} > >(tee -a $mainlog) 2> >(tee -a $mainlog |tee -a $daylog >&2)

logitem "ending copy ######################"


#replace the symlink

logitem "removing old symlink"
rm $curbackup > >(tee -a $mainlog) 2> >(tee -a $mainlog |tee -a $daylog >&2)
logitem "creating new symlinnk"
ln -s "$newbackup" "$curbackup" > >(tee -a $mainlog) 2> >(tee -a $mainlog |tee -a $daylog >&2)


#run rsync for each directory specified
logitem "running rsync"
#rsync --stats --delete --modify-window=3 -ahh /home/ $curbackup  > >(tee -a $mainlog) 2> >(tee -a $mainlog |tee -a $daylog >&2)

rsync --stats --delete --modify-window=3 -ahhze "ssh -p722" root@${forhost}:/home/ $curbackup > >(tee -a $mainlog) 2> >(tee -a $mainlog |tee -a $daylog >&2)

 
############ parse the rsync summery output and log it in readable format


############ determin form rsync summery output if there are any new changes in logged data, if not, remove current backup.
	## replace with symlink??
 

#run email notification

#reliese lock file
rm ${lockfile} > >(tee -a $mainlog) 2> >(tee -a $mainlog |tee -a $daylog >&2)

logitem "removed lock file and finshing"
daylogitem "daily remote backup of ${forhost} finished"
summerylogitem "daily remote backup of ${forhost} finished"




