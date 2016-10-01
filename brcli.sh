#!/usr/bin/env bash
#
# Backup & Restore CLI for Dropbox.
#
# Version: 1.0.0
# Author: Ahmad Awais.
# Author URI: http://AhmadAwais.com/

#.# Install Dropbox uploader
#  @link https://github.com/andreafabrizi/Dropbox-Uploader
wget -qO dbx https://git.io/vBypP
sudo chmod +x ./dbx
sudo install ./dbx /usr/local/bin/dbx

# Check all params for the config.
for i in "$@" ; do
	# Is backup.
	if [[ $i == "--backup" || $i == "-b" ]] ; then
		is_backup="yes"
	fi

	# Is backup all.
	if [[ $i == "--backup-all" || $i == "-ba" ]] ; then
		is_backup_all="yes"
	fi

	# Is restore.
	if [[ $i == "--restore" || $i == "-r" ]] ; then
		is_restore="yes"
	fi

	# Is restore all.
	if [[ $i == "--restore-all" || $i == "-ra" ]] ; then
		is_restore_all="yes"
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
DATEFORM=$(date +"%Y-%m-%d")

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
if [[ "$is_backup_all" == "yes" ]]; then
	# Start the loop
	for SITE in ${SITELIST[@]}; do
		echo "——————————————————————————————————"
		echo "⚡️  Backing up the site: $SITE_NAME..."
		echo "——————————————————————————————————"

		# Enter the WordPress folder.
		cd $SITESTORE/$SITE

		# Check of the backup folder for this site exits.
		if [ ! -e $BACKUPPATH/$SITE ]; then
			mkdir -p $BACKUPPATH/$SITE
		fi

		echo "——————————————————————————————————"
		echo "⏲  Creating Files Backup for: $SITE_NAME..."
		echo "——————————————————————————————————"

		# Back up the WordPress folder.
		tar -czf $BACKUPPATH/$SITE/$DATEFORM-$SITE.tar.gz .

		echo "——————————————————————————————————"
		echo "⏲  Creating Database Backup for: $SITE_NAME..."
		echo "——————————————————————————————————"

		# Back up the WordPress database.
		wp db export $BACKUPPATH/$SITE/$DATEFORM-$SITE.sql --allow-root --path=$SITESTORE/$SITE/htdocs
		tar -czf $BACKUPPATH/$SITE/$DATEFORM-$SITE.sql.gz $BACKUPPATH/$SITE/$DATEFORM-$SITE.sql
		rm $BACKUPPATH/$SITE/$DATEFORM-$SITE.sql

		echo "——————————————————————————————————"
		echo "⏲  Uploading Files & Database Backup to Dropbox for: $SITE_NAME..."
		echo "——————————————————————————————————"

		# Upload packages to Dropbox.
		dbx upload $BACKUPPATH/$SITE/$DATEFORM-$SITE.tar.gz /$SITE/
		dbx upload $BACKUPPATH/$SITE/$DATEFORM-$SITE.sql.gz /$SITE/

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

	# If you want to delete all local backups
	# rm -rf $BACKUPPATH/*

	# Delete old backups locally over DAYSKEEP days old.
	# find $BACKUPPATH -type d -mtime +$DAYSKEEP -exec rm -rf {} \;

	# Fix permissions.
	sudo chown -R www-data:www-data $SITESTORE
	sudo find $SITESTORE -type f -exec chmod 644 {} +
	sudo find $SITESTORE -type d -exec chmod 755 {} +
fi


#.# Backup Single Site.
#
#   Backup for single sites.
#
#   @since 1.0.0
if [[ "$is_backup" == "yes" ]]; then
	echo "——————————————————————————————————"
	echo "👉  Enter Name of a single site [E.g. site.tld]:"
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
	tar -czf $BACKUPPATH/$SITE_NAME/$DATEFORM-$SITE_NAME.tar.gz .

	echo "——————————————————————————————————"
	echo "⏲  Creating Database Backup for: $SITE_NAME..."
	echo "——————————————————————————————————"

	# Back up the WordPress database.
	wp db export $BACKUPPATH/$SITE_NAME/$DATEFORM-$SITE_NAME.sql --allow-root --path=$SITE_PATH/htdocs
	tar -czf $BACKUPPATH/$SITE_NAME/$DATEFORM-$SITE_NAME.sql.gz $BACKUPPATH/$SITE_NAME/$DATEFORM-$SITE_NAME.sql
	rm $BACKUPPATH/$SITE_NAME/$DATEFORM-$SITE_NAME.sql

	echo "——————————————————————————————————"
	echo "⏲  Uploading Files & Database Backup to Dropbox for: $SITE_NAME..."
	echo "——————————————————————————————————"

	# Upload packages to Dropbox.
	dbx upload $BACKUPPATH/$SITE_NAME/$DATEFORM-$SITE_NAME.tar.gz /$SITE_NAME/
	dbx upload $BACKUPPATH/$SITE_NAME/$DATEFORM-$SITE_NAME.sql.gz /$SITE_NAME/

	# Check if there are old backups and delete them.
	EXISTS=$(dbx list /$SITE_NAME | grep -E $DAYSKEPT.*.tar.gz | awk '{print $3}')
	if [ ! -z $EXISTS ]; then
		dbx delete /$SITE_NAME/$DAYSKEPT-$SITE_NAME.tar.gz
		dbx delete /$SITE_NAME/$DAYSKEPT-$SITE_NAME.sql.gz
	fi

	echo "——————————————————————————————————"
	echo "🔥  $SITE_NAME Backup Complete!"
	echo "——————————————————————————————————"


	# If you want to delete all local backups
	# rm -rf $BACKUPPATH/*

	# Delete old backups locally over DAYSKEEP days old.
	# find $BACKUPPATH -type d -mtime +$DAYSKEEP -exec rm -rf {} \;

	# Fix permissions.
	sudo chown -R www-data:www-data $SITESTORE
	sudo find $SITESTORE -type f -exec chmod 644 {} +
	sudo find $SITESTORE -type d -exec chmod 755 {} +
fi

#.# Restore All.
#
#   Restore all sites.
#
#   @since 1.0.0
if [[ "$is_restore_all" == "yes" ]]; then

	# Start the loop.
	for SITE in ${SITELIST[@]}; do
		echo "——————————————————————————————————"
		echo "⚡️  Restoring site: $SITE_NAME..."
		echo "——————————————————————————————————"

		#if you want to delete all local backups
		rm -rf $BACKUPPATH/$SITE

		if [ ! -e $BACKUPPATH/$SITE ]; then
			mkdir -p $BACKUPPATH/$SITE
		fi

		cd $BACKUPPATH/$SITE

		echo "——————————————————————————————————"
		echo "⏲  Download site: $SITE_NAME..."
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
		tar -xvzf $BACKUPPATH/$SITE/$DATEFORM-$SITE.tar.gz -C $BACKUPPATH/$SITE/files/ #--strip-components=1

		echo "FILEs extracted"

		tar -xvzf $BACKUPPATH/$SITE/$DATEFORM-$SITE.sql.gz -C $BACKUPPATH/$SITE/db/ --strip-components=3
		echo "Db extracted"

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
		wp db import $BACKUPPATH/$SITE/db/$DATEFORM-$SITE.sql --path=$SITESTORE/$SITE/htdocs/ --allow-root
		wp db repair --path=$SITESTORE/$SITE/htdocs/ --allow-root
		wp db optimize --path=$SITESTORE/$SITE/htdocs/ --allow-root

		echo "——————————————————————————————————"
		echo "⏲  Fixing permissions..."
		echo "——————————————————————————————————"

		sudo chown -R www-data:www-data $SITESTORE
		sudo find $SITESTORE -type f -exec chmod 644 {} +
		sudo find $SITESTORE -type d -exec chmod 755 {} +

		echo "——————————————————————————————————"
		echo "🔥  $SITE has been restored!"
		echo "——————————————————————————————————"
	done
fi

if [ $# -eq 0 ]; then
	echo "No arguments provided"
	echo "Usage: brcli [ -b |--backup ], [ -ba | --backup_all ], [ -r | --resotre ], [ -ra | --restore-all ], and [ -h | help ]"
	exit 1
fi
