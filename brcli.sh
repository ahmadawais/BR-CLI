#!/usr/bin/env bash
#
# Backup & Restore CLI for Dropbox.
#
# Version: 1.1.0
# Author: Ahmad Awais.
# Author URI: http://AhmadAwais.com/
#
# Props & Credits: andreafabrizi, wpbullet (Mike Adreasen)

# Colors.
#
# colors from tput
# http://stackoverflow.com/a/20983251/950111
# Usage:
# echo "${redb}red text ${gb}green text${r}"
bb=`tput setab 0` #set background black
bf=`tput setaf 0` #set foreground black
gb=`tput setab 2` # set background green
gf=`tput setab 2` # set background green
blb=`tput setab 4` # set background blue
blf=`tput setaf 4` # set foreground blue
rb=`tput setab 1` # set background red
rf=`tput setaf 1` # set foreground red
wb=`tput setab 7` # set background white
wf=`tput setaf 7` # set foreground white
r=`tput sgr0`     # r to defaults

clear
cd ~

# Backup file name that gets downloaded.
BACKUP_FILE=b.tar.gz

echo "—"
echo "${gb}${bf} BR CLI ⚡️  ${r}"
echo "${wb}${bf} Version 1.1.0 ${r}"
echo "${wb}${bf} Backup & Restore CLI for EasyEngine with Dropbox.${r}"
echo "—"

echo "${gb}${bf}  ℹ️  Pre CEM CLI Checklist: ${r}"
echo "${wb}${bf}  ␥  1. Have you configured Dropbox-Uploader? If not then install and configure it!${r} (INFO: https://github.com/andreafabrizi/Dropbox-Uploader)?"
echo "${wb}${bf}  ␥  2. Make sure the Dropbox-Uploader file is excuteable and is rename to 'dbx'?${r}"
echo "${blb}${bf}  INFO: All the above steps above are required for BR CLI to work. ${r}"

#.# Install Dropbox uploader
#  @link https://github.com/andreafabrizi/Dropbox-Uploader
# wget -qO dbx https://git.io/vBypP
# sudo chmod +x ./dbx
# sudo install ./dbx /usr/local/bin/dbx



# Check all params for the config.
for i in "$@" ; do
	# Is backup.
	if [[ $i == "--backup" || $i == "-b" ]] ; then
		IS_BACKUP="yes"
	fi

	# Is backup all.
	if [[ $i == "--backup-all" || $i == "-ba" ]] ; then
		IS_BACKUP_ALL="yes"
	fi

	# Is restore.
	if [[ $i == "--restore" || $i == "-r" ]] ; then
		IS_RESTORE="yes"
	fi

	# Is restore all.
	if [[ $i == "--restore-all" || $i == "-ra" ]] ; then
		IS_RESTORE_ALL="yes"
	fi

	# Help.
	if [[ $i == "-h" || $i == "help" ]] ; then
		echo "——————————————————————————————————"
		echo "⚡️ Usage: brcli [ -b |--backup ], [ -ba | --backup_all ], [ -r | --resotre ], [ -ra | --restore-all ], and [ -h | help ]"
		echo "⚡️  - [ -h | help ] Usage help."
		echo "⚡️  - [ -b | --backup ] Takes backup of a particular site & its databases."
		echo "⚡️  - [ -ba | --backup_all ] Takes backup of all sites & their databases in /var/www/ except html and 22222 folders."
		echo "⚡️  - [ -r | --restore ] Restores a particular site in /var/www/ as well as its database."
		echo "⚡️  - [ -ra | --restore-all ] Restores all sites in /var/www/ as well as their databases."
		echo "——————————————————————————————————"
	fi
done

# Define local path for backups.
BACKUPPATH=~/backups

# Path to WordPress installations.
SITESTORE=/var/www/

# Date prefix for the backup files
DATE=$(date +"%Y-%m-%d")

# Days to retain the backups.
DAYSKEEP=7

# Calculate days through the filename prefix.
DAYSKEPT=$(date +"%Y-%m-%d" -d "-$DAYSKEEP days")

# Create array of sites based on folder names and ignore '22222' and 'html' folders of EasyEngine.
SITELIST=($(ls -lh /var/www -I22222 -Ihtml | awk '{print $9}'))

# Make sure the backup folder exists.
mkdir -p $BACKUPPATH

#.# Backup All.
#
#   Backup all sites.
#
#   @since 1.0.0
if [[ "$IS_BACKUP_ALL" == "yes" ]]; then
	# Start the loop
	for SITE in ${SITELIST[@]}; do
		echo "——————————————————————————————————"
		echo "⚡️  Backing up the site: $SITE..."
		echo "——————————————————————————————————"

		# Enter the WordPress folder.
		cd $SITESTORE/$SITE

		# Check of the backup folder for this site exits.
		if [ ! -e $BACKUPPATH/$SITE ]; then
			mkdir -p $BACKUPPATH/$SITE
		fi

		echo "——————————————————————————————————"
		echo "⏲  Creating Files Backup for: $SITE..."
		echo "——————————————————————————————————"

		# Back up the WordPress folder.
		tar -czf $BACKUPPATH/$SITE/$DATE-$SITE.tar.gz .

		echo "——————————————————————————————————"
		echo "⏲  Creating Database Backup for: $SITE..."
		echo "——————————————————————————————————"

		# Back up the WordPress database.
		wp db export $BACKUPPATH/$SITE/$DATE-$SITE.sql --allow-root --path=$SITESTORE/$SITE/htdocs
		tar -czf $BACKUPPATH/$SITE/$DATE-$SITE.sql.gz $BACKUPPATH/$SITE/$DATE-$SITE.sql
		rm $BACKUPPATH/$SITE/$DATE-$SITE.sql

		echo "——————————————————————————————————"
		echo "⏲  Uploading Files & Database Backup to Dropbox for: $SITE..."
		echo "——————————————————————————————————"

		# Upload packages to Dropbox.
		dbx upload $BACKUPPATH/$SITE/$DATE-$SITE.tar.gz /$SITE/
		dbx upload $BACKUPPATH/$SITE/$DATE-$SITE.sql.gz /$SITE/

		# Check if there are old backups and delete them.
		EXISTS=$(dbx list /$SITE | grep -E $DAYSKEPT.*.tar.gz | awk '{print $3}')
		if [ ! -z $EXISTS ]; then
			dbx delete /$SITE/$DAYSKEPT-$SITE.tar.gz
			dbx delete /$SITE/$DAYSKEPT-$SITE.sql.gz
		fi

		echo "——————————————————————————————————"
		echo "🔥  $SITE Backup Complete!"
		echo "——————————————————————————————————"

	done

	# Delete all local backups.
	rm -rf $BACKUPPATH/$SITE

	# Delete old backups locally over DAYSKEEP days old.
	# find $BACKUPPATH -type d -mtime +$DAYSKEEP -exec rm -rf {} \;

	# Fix permissions.
	sudo chown -R www-data:www-data $SITESTORE/$SITE/htdocs/
	sudo find $SITESTORE/$SITE/htdocs/ -type f -exec chmod 644 {} +
	sudo find $SITESTORE/$SITE/htdocs/ -type d -exec chmod 755 {} +
fi


#.# Backup Single Site.
#
#   Backup for single sites.
#
#   @since 1.0.0
if [[ "$IS_BACKUP" == "yes" ]]; then
	echo "——————————————————————————————————"
	echo "👉  Enter SITE NAME of a single site to backup [E.g. site.tld]:"
	echo "——————————————————————————————————"
	read -r SITE_NAME

	# $SITE_PATH path for site.
	SITE_PATH=/var/www/"$SITE_NAME"/

	echo "——————————————————————————————————"
	echo "⚡️  Backing up the site: $SITE_NAME..."
	echo "——————————————————————————————————"

	# Enter the WordPress folder.
	cd $SITE_PATH

	# Check of the backup folder for this site exits.
	if [ ! -e $BACKUPPATH/$SITE_NAME ]; then
		mkdir -p $BACKUPPATH/$SITE_NAME
	fi

	echo "——————————————————————————————————"
	echo "⏲  Creating Files Backup for: $SITE_NAME..."
	echo "——————————————————————————————————"

	# Back up the WordPress folder.
	tar -czf $BACKUPPATH/$SITE_NAME/$DATE-$SITE_NAME.tar.gz .

	echo "——————————————————————————————————"
	echo "⏲  Creating Database Backup for: $SITE_NAME..."
	echo "——————————————————————————————————"

	# Back up the WordPress database.
	wp db export $BACKUPPATH/$SITE_NAME/$DATE-$SITE_NAME.sql --allow-root --path=$SITE_PATH/htdocs
	tar -czf $BACKUPPATH/$SITE_NAME/$DATE-$SITE_NAME.sql.gz $BACKUPPATH/$SITE_NAME/$DATE-$SITE_NAME.sql
	rm $BACKUPPATH/$SITE_NAME/$DATE-$SITE_NAME.sql

	echo "——————————————————————————————————"
	echo "⏲  Uploading Files & Database Backup to Dropbox for: $SITE_NAME..."
	echo "——————————————————————————————————"

	# Upload packages to Dropbox.
	dbx upload $BACKUPPATH/$SITE_NAME/$DATE-$SITE_NAME.tar.gz /$SITE_NAME/
	dbx upload $BACKUPPATH/$SITE_NAME/$DATE-$SITE_NAME.sql.gz /$SITE_NAME/

	# Check if there are old backups and delete them.
	EXISTS=$(dbx list /$SITE_NAME | grep -E $DAYSKEPT.*.tar.gz | awk '{print $3}')
	if [ ! -z $EXISTS ]; then
		dbx delete /$SITE_NAME/$DAYSKEPT-$SITE_NAME.tar.gz
		dbx delete /$SITE_NAME/$DAYSKEPT-$SITE_NAME.sql.gz
	fi

	echo "——————————————————————————————————"
	echo "🔥  $SITE_NAME Backup Complete!"
	echo "——————————————————————————————————"


	# Delete all local backups.
	rm -rf $BACKUPPATH/$SITE_NAME

	# Delete old backups locally over DAYSKEEP days old.
	# find $BACKUPPATH -type d -mtime +$DAYSKEEP -exec rm -rf {} \;

	# Fix permissions.
	sudo chown -R www-data:www-data $SITE_PATH/htdocs/
	sudo find $SITE_PATH/htdocs/ -type f -exec chmod 644 {} +
	sudo find $SITE_PATH/htdocs/ -type d -exec chmod 755 {} +
fi

#.# Restore All.
#
#   Restore all sites.
#
#   @since 1.0.0
if [[ "$IS_RESTORE_ALL" == "yes" ]]; then

	# Start the loop.
	for SITE in ${SITELIST[@]}; do
		echo "——————————————————————————————————"
		echo "⚡️  Restoring site: $SITE..."
		echo "——————————————————————————————————"

		# Delete all local backups.
		rm -rf $BACKUPPATH/$SITE

		if [ ! -e $BACKUPPATH/$SITE ]; then
			mkdir -p $BACKUPPATH/$SITE
		fi

		cd $BACKUPPATH/$SITE

		echo "——————————————————————————————————"
		echo "⏲  Download site: $SITE..."
		echo "——————————————————————————————————"

		dbx download $SITE $BACKUPPATH/

		echo "——————————————————————————————————"
		echo "🔥  Backup Download Successful 💯"
		echo "——————————————————————————————————"

		# Remove new WP content.
		rm -rf $SITESTORE/$SITE/*

		echo "——————————————————————————————————"
		echo "⏲  Removing current site files & resetting the database..."
		echo "——————————————————————————————————"

		mkdir -p $BACKUPPATH/$SITE/files
		mkdir -p $BACKUPPATH/$SITE/db

		echo "——————————————————————————————————"
		echo "⏲  Now extracting the backup..."
		echo "——————————————————————————————————"

		# Un tar the backup,
		# -C To extract an archive to a directory different from the current.
		# --strip-components=1 to remove the root(first level) directory inside the zip.
		tar -xvzf $BACKUPPATH/$SITE/$DATE-$SITE.tar.gz -C $BACKUPPATH/$SITE/files/ #--strip-components=1

		echo "FILES extracted"

		# Remove the backup file.
		rm -f $BACKUPPATH/$SITE/$DATE-$SITE.tar.gz

		tar -xvzf $BACKUPPATH/$SITE/$DATE-$SITE.sql.gz -C $BACKUPPATH/$SITE/db/ --strip-components=3
		echo "Db extracted"

		# Remove the backup file.
		rm -f $BACKUPPATH/$SITE/$DATE-$SITE.sql.gz

		echo "——————————————————————————————————"
		echo "⏲  Restoring the files..."
		echo "——————————————————————————————————"

		# Add the backup content.
		rsync -avz --info=progress2 --stats --human-readable $BACKUPPATH/$SITE/files/* $SITESTORE/$SITE #--exclude 'wp-config.php' --exclude 'wp-config-sample.php' #--info=progress2 --progress --stats --human-readable

		echo "——————————————————————————————————"
		echo "⏲  Restoring the database..."
		echo "——————————————————————————————————"

		# Reset the database.
		wp db reset --yes --path=$SITESTORE/$SITE/htdocs/ --allow-root

		# Import the DB of old site to new site.
		wp db import $BACKUPPATH/$SITE/db/$DATE-$SITE.sql --path=$SITESTORE/$SITE/htdocs/ --allow-root
		wp db repair --path=$SITESTORE/$SITE/htdocs/ --allow-root
		wp db optimize --path=$SITESTORE/$SITE/htdocs/ --allow-root

		echo "——————————————————————————————————"
		echo "⏲  Fixing permissions..."
		echo "——————————————————————————————————"

		sudo chown -R www-data:www-data $SITESTORE/$SITE/htdocs/
		sudo find $SITESTORE/$SITE/htdocs/ -type f -exec chmod 644 {} +
		sudo find $SITESTORE/$SITE/htdocs/ -type d -exec chmod 755 {} +

		# Delete all local backups.
		rm -rf $BACKUPPATH/$SITE

		echo "——————————————————————————————————"
		echo "🔥  $SITE has been restored!"
		echo "——————————————————————————————————"
	done
fi

#.# Restore Single Site.
#
#   Restore for single site.
#
#   Usage: brcli -r
#
#   @since 1.0.0
if [[ "$IS_RESTORE" == "yes" ]]; then
	echo "——————————————————————————————————"
	echo "👉  Enter SITE NAME of a single site to restore [E.g. site.ext]:"
	echo "——————————————————————————————————"
	read -r SITE_NAME

	echo "——————————————————————————————————"
	echo "👉  Enter DATE of backup to restore [E.g. 2016-10-01]:"
	echo "——————————————————————————————————"
	echo "⚡️  Following are the list of backups avaialble for $SITE_NAME:"
	dbx list $SITE_NAME
	echo "——————————————————————————————————"
	read -r DATE

	# $SITE_PATH path for site.
	SITE_PATH=/var/www/"$SITE_NAME"/

	echo "——————————————————————————————————"
	echo "⚡️  Restoring site: $SITE_NAME..."
	echo "——————————————————————————————————"

	# Delete all local backups.
	rm -rf $BACKUPPATH/$SITE_NAME

	if [ ! -e $BACKUPPATH/$SITE_NAME ]; then
		mkdir -p $BACKUPPATH/$SITE_NAME
	fi

	cd $BACKUPPATH/$SITE_NAME

	echo "——————————————————————————————————"
	echo "⏲  Download site: $SITE_NAME..."
	echo "——————————————————————————————————"

	dbx download $SITE_NAME/$DATE-$SITE_NAME.tar.gz $BACKUPPATH/
	dbx download $SITE_NAME/$DATE-$SITE_NAME.sql.gz $BACKUPPATH/

	echo "——————————————————————————————————"
	echo "🔥  Backup Download Successful 💯"
	echo "——————————————————————————————————"

	# Remove new WP content.
	rm -rf $SITE_PATH/*

	echo "——————————————————————————————————"
	echo "⏲  Removing current site files & resetting the database..."
	echo "——————————————————————————————————"

	mkdir -p $BACKUPPATH/$SITE_NAME/files
	mkdir -p $BACKUPPATH/$SITE_NAME/db

	echo "——————————————————————————————————"
	echo "⏲  Now extracting the backup..."
	echo "——————————————————————————————————"

	# Un tar the backup,
	# -C To extract an archive to a directory different from the current.
	# --strip-components=1 to remove the root(first level) directory inside the zip.
	tar -xvzf $BACKUPPATH/$SITE_NAME/$DATE-$SITE_NAME.tar.gz -C $BACKUPPATH/$SITE_NAME/files/ #--strip-components=1

	echo "FILEs extracted"

	# Remove the backup file.
	rm -f $BACKUPPATH/$SITE/$DATE-$SITE.tar.gz

	tar -xvzf $BACKUPPATH/$SITE_NAME/$DATE-$SITE_NAME.sql.gz -C $BACKUPPATH/$SITE_NAME/db/ --strip-components=3

	echo "Db extracted"

	# Remove the backup file.
	rm -f $BACKUPPATH/$SITE/$DATE-$SITE.sql.gz

	echo "——————————————————————————————————"
	echo "⏲  Restoring the files..."
	echo "——————————————————————————————————"

	# Add the backup content.
	rsync -avz --info=progress2 --stats --human-readable $BACKUPPATH/$SITE_NAME/files/* $SITE_PATH #--exclude 'wp-config.php' --exclude 'wp-config-sample.php' #--info=progress2 --progress --stats --human-readable

	echo "——————————————————————————————————"
	echo "⏲  Restoring the database..."
	echo "——————————————————————————————————"

	# Reset the database.
	wp db reset --yes --path=$SITESTORE/$SITE_NAME/htdocs/ --allow-root

	# Import the DB of old site to new site.
	wp db import $BACKUPPATH/$SITE_NAME/db/$DATE-$SITE_NAME.sql --path=$SITE_PATH/htdocs/ --allow-root
	wp db repair --path=$SITE_PATH/htdocs/ --allow-root
	wp db optimize --path=$SITE_PATH/htdocs/ --allow-root

	echo "——————————————————————————————————"
	echo "⏲  Fixing permissions..."
	echo "——————————————————————————————————"

	sudo chown -R www-data:www-data $SITE_PATH/htdocs/
	sudo find $SITE_PATH/htdocs/ -type f -exec chmod 644 {} +
	sudo find $SITE_PATH/htdocs/ -type d -exec chmod 755 {} +

	# Delete all local backups.
	rm -rf $BACKUPPATH/$SITE_NAME

	echo "——————————————————————————————————"
	echo "🔥  $SITE_NAME has been restored!"
	echo "——————————————————————————————————"
fi

#.# If no parameter is added.
if [ $# -eq 0 ]; then
	echo "——————————————————————————————————"
	echo "❌ No arguments provided!"
	echo "——————————————————————————————————"
	echo "Usage: brcli [ -b |--backup ], [ -ba | --backup_all ], [ -r | --resotre ], [ -ra | --restore-all ], and [ -h | help ]"
	echo "——————————————————————————————————"
	exit 1
fi
