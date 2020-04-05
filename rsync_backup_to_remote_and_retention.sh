#!/bin/bash
# About this script: It is aimed for the Linux computer which is allowed to connect (without password prompt) remote backup server via SSH
# Each time this script is run, user defined directory and its subdirectories of the local Linux computer are mirrored using rsync over SSH to remote Linux server.
# User defined number of previous backups are retained and exceeding oldest backups are removed.

# 1. update variables in two following paragraphs

# backup server IP:
bsip=1.2.3.4
# backup server username:
bsu=root
# backup server SSH port number:
bssp=22
# backup server (remote) directory where backup will be stored (NOT ending by the slash):
bsd=/backup
# local directory containing data to be backed up (have to end by the slash):
dirtobackup=/home/root/filestobackup/

# maximum backups to keep on backup server (subtract one). Example 5 daily, 3 weekly, 2 monthly, 2 annually:
daily=4
weekly=2
monthly=1
annually=1

# 2. chmod 750 /path/to/thisscript
# 3. make sure you have ssh password-less access to backup server: ssh -l root 1.2.3.4 "apt install rsync find -y;df -h"
# if not, use ssh-keygen and ssh-copy-id 1.2.3.4
# 4. Following cronjobs can be set to run this script at various periods:
# @daily root /bin/bash /path/to/thisscript daily
# @weekly root /bin/bash /path/to/thisscript weekly
# @monthly root /bin/bash /path/to/thisscript monthly
# @annually root /bin/bash /path/to/thisscript annually
# the parameter at the end of the commands is only necessary to put the backup into appropriate directory and to preserve only defined number of backups

##############################################

if [[ "$1" == "daily" ]];then max=$daily;elif [[ "$1" == "weekly" ]];then max=$weekly;elif [[ "$1" == "monthly" ]];then max=$monthly;elif [[ "$1" == "annually" ]];then max=$annually;else echo "Script has to be launched with parameter to define backup period: daily, weekly, monthly or annually" && exit;fi
datetoday="$(date --rfc-3339=date)"

firststeps="$(ssh -p$bssp $bsu@$bsip "mkdir -p $bsd $bsd/daily $bsd/weekly $bsd/monthly $bsd/annually && ls -l $bsd/* 2>/dev/null")"
if [[ "$firststeps" == *"$datetoday"* ]];then echo "Backup directory $datetoday already exist. Nothing to do." && exit;fi

# make backup
rsync -e "ssh -p$bssp" --delete -aAX --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} $dirtobackup $bsu@$bsip:$bsd/latest/

numberofbackups="$(ssh -p$bssp $bsu@$bsip ls -l $bsd/"$1"|grep -c -)"
if [[ "$numberofbackups" -gt "$max" ]];then
# find oldest daily backup
oldest="$(ssh -p$bssp $bsu@$bsip ls -tA1 $bsd/"$1"|grep -v \"\\.\"|tail -n 1)"
# delete oldest daily backup
ssh -p$bssp $bsu@$bsip "find $bsd/\"$1\"/$oldest -delete"
fi
# copy retention backup
ssh -p$bssp $bsu@$bsip "rsync -a $bsd/latest $bsd/\"$1\"/"
#rand="$(head /dev/urandom|tr -dc a-z|head -c 4)"
ssh -p$bssp $bsu@$bsip "mv $bsd/\"$1\"/latest $bsd/\"$1\"/$datetoday"

