#### ABOUT ####

echo "This SSH/rsync backup script allows:
- setup password-less ssh access to remote server (backup server)
- can be set to backup local server directory to remote server directory via SSH using rsync
- script can also delete remote server backups older than X hours"

#### VARIABLES ####

src=/backup/
dest=/backup/cpanelvps/
destusr=root
destip=1.2.3.4
destport=22

# delete old backup fils older X hours from reote server to prevent disk full
# This can be disk I/O intensive task. If enabled, it runs each time this script run
# deletehours = files older than X hours will be deleted
deleteold=y
deletehours=72

# print variables
echo "Source: $src and destination: $destusr@$destip:$dest"

#### SET WHETHER SCRIPT ASK FOR SSH GENERATION OR DO BACKUP IMMEDIATELLY ###

# generate ssh key and upload to remote server (first time/initial setup) ???
# yes, we setup new remoteserver backup = y
# no, just do rsync, we already have password-less access = n
# ask prompt on script run = <empty> -> keygen=
keygen=n

#### PROMPT TO ASK IF SSH GENERATION IS NEEDED ####

if [ "$keygen" == "" ];then
echo "First time generate SSH access key and copy to remote server to setup passwordless access.
y = yes
other key = just do rsync now"
read keygen
fi

#### SSH ACCESS KEY GENERATION AND UPLOAD ####

if [ "$keygen" == "y" ];then

ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub "$destip -p $destport"
ssh -p $destport $destip mkdir -p $dest

else

#### PRUNE OLD BACKUPS ON REMOTE SERVER ####

if [ "$deleteold" == "y" ];then
echo "Deleting files older $deletehours hours in $destusr@$destip:$dest"
ssh -p $destport $destip tmpwatch -m $deletehours $dest
fi

#### DOING NEW BACKUP VIA RSYNC ####


rsync -av $src -e "ssh -p $destport" $destusr@$destip:$dest
# -z to compress (higher cpu, less traffic)
# -v verbose (toomany files, unnecessary output)

fi
