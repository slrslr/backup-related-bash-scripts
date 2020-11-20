# Linux bash scripts related to backups

**backups_weeklymonthlyannually** - if you are having one directory into which are added daily new sub-directories containing backup files, then you may run this script to handle these files and move them to weekly, monthly, annually folders and define how long to keep these

**rsync_backup_to_remote_and_retention.sh** - Each time this script is run, user defined directory and its subdirectories of the local Linux computer are mirrored using rsync over SSH to remote Linux server. User defined number of previous backups are retained and exceeding oldest backups are removed.

**zpoolrestorebadfiles** - If you do not want to bother manually delete/copy the permanent erroneous/corrupted files (per "sudo zpool status -v") from backup to your ZFS filesystem. Then this script will parse the zpool status output and prompt you about the removal/replacement of each file.
