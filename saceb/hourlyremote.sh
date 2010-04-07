#! /bin/bash
##does local snapshot once per hour
## may be called more often without concequence
## authur JR Peterson
## date 2010-01-22

forhost="sace"
#forhost="138.253.8.20"


## send email procedure

email ()
{
	logitem "email called with: $1"
}

##  end of send email procedure

## start of log item 

logitem ()
{
	echo "$1"
	echo "`date '+%Y-%m-%d.%H%M-%S'` -- $1" >> "$mainlog"
}
daylogitem ()
{
	echo "$1"
	echo "`date '+%Y-%m-%d.%H%M-%S'` -- $1" >> "$daylog"
}
summerylogitem ()
{
	echo "$1"
	echo "`date '+%Y-%m-%d.%H%M-%S'` -- $1" >> "$summerylog"
}

## end of log item


#setup logging
dt=`date '+%Y-%m-%d.%H%M-%S'`
day=`date '+%Y-%m-%d'`

mainlog="/var/log/backup/hourly/${dt}.log"
daylog="/var/log/backup/hourly/${day}.log"
summerylog="/var/log/backup/backup.log"


logitem "hourly local backup started"
daylogitem "hourly local backup started"

#locate symlink to latest backup else send error email and do a first backup
### needs work

curbackup="/archive/hourly/latest"
logitem "basing backup on old backup in symlink $curbackup"

#check and then create lock file
if [ -f "/archive/hourly/lock.lock" ] 
then 
	logitem "hourly local backup failed -- lock file already exists -- aborting"
	daylogitem "hourly local backup failed -- lock file already exists -- aborting"
	summerylogitem "hourly local backup failed -- lock file already exists -- aborting"
	exit 5
fi

touch /archive/hourly/lock.lock

logitem "lock file created"


#if first backup of day record this fact in variable daily
if [ -f  "/archive/hourly/bak${day}*" ]
then
	logitem "is not first backup of day"
	daily=0
else
	logitem "is first backup of day"
	daily=1
fi

#xx if daily, run backup thinning -- run it as part of daily job

#create new folder

newbackup=/archive/hourly/bak${dt}

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
rsync --stats --delete --modify-window=3 -ahh /home/ $curbackup  > >(tee -a $mainlog) 2> >(tee -a $mainlog |tee -a $daylog >&2)

 

#run email notification

#reliese lock file
rm /archive/hourly/lock.lock > >(tee -a $mainlog) 2> >(tee -a $mainlog |tee -a $daylog >&2)

logitem "removed lock file and finshing"
daylogitem "hourly local backup finished"
summerylogitem "hourly local backup complete"








