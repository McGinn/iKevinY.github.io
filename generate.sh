#!/bin/bash
cd ~/Sites/Kevin\ Yap
pelican -s settings.py

# Run file copying/deletion commands
cp favicon.ico output/favicon.ico
cp robots.txt output/robots.txt
cp .htaccess output/.htaccess
cp -R uploads/ output/uploads/
find . -name '*.DS_Store' -type f -delete || echo "Error deleting .DS_Store files."

printf "\e[0;32mSite generated successfully.\e[0m\n"

function confirm {
	read -n1 -p "Confirm upload via rsync (y/n): " confirm
	printf "\n"
	case $confirm in
	  y|Y)
			rsync --recursive --checksum --delete ~/Sites/Kevin\ Yap/output/ keviny_kevinyap@ssh.phx.nearlyfreespeech.net:/home/public/
			printf "\e[0;32mOutput directory updated using rsync.\e[0m\n"
			exit ;;
	  n|N)
			printf "\e[0;31mrsync terminated.\e[0m\n"
			exit ;;
	  *)
			printf "Unknown input. "
			confirm ;;
	esac
}

# Check for options
if [ -z "$1" ]; then # no flag
	exit
elif [ $1 = "-b" ]; then # backup
	backupPath=$(mount | grep '/Volumes/*' | awk 'NR==1{print $3}')

	if [ -z $backupPath ]; then
		printf "\e[0;31mNo external drives connected.\e[0m\n"
		exit
	else
		rsync -a ~/Sites/Kevin\ Yap/ $backupPath/Website\ Backup
		printf "\e[0;36mSite files backed up to $backupPath.\e[0m\n"
		exit
	fi
elif [ $1 = "-u" ]; then # upload
	echo "Beginning dry run of rsync."
	rsync --recursive --dry-run --verbose --checksum --human-readable --delete ~/Sites/Kevin\ Yap/output/ keviny_kevinyap@ssh.phx.nearlyfreespeech.net:/home/public/
	confirm
fi