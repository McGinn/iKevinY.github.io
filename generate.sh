#!/bin/bash
cd ~/Sites/Kevin\ Yap
pelican -q -s settings.py

# Run file copying/deletion commands
cd ~/Sites/Kevin\ Yap/output
cp ../favicon.ico favicon.ico
cp ../robots.txt robots.txt
cp ../.htaccess .htaccess
cp ../CNAME CNAME
cp -R ../uploads/ uploads/
find . -name '*.DS_Store' -type f -delete || echo "Error deleting .DS_Store files."

printf "\e[0;32mSite generated successfully.\e[0m\n"

confirm() {
	read -n1 -p "$1" input
	printf "\n"

	case $input in
	  y|Y)
			return 0 ;;
	  n|N)
			return 1 ;;
	  *)
			printf "Unknown input. "
			confirm "$1" ;;
	esac
}

# Check for backup/upload options
if [ -z "$1" ]; then # no flag
	exit
elif [ $1 = "-p" ]; then
	python -m SimpleHTTPServer
elif [ $1 = "-u" ] || [ $1 = "-U" ]; then
	if confirm $"Commit output directory to master branch? (y/n): "; then
		cd ~/Sites/Kevin\ Yap
		commitHash=$(git rev-parse HEAD)

		cd ~/Sites/Kevin\ Yap/output
		git checkout master
		git add *
		if [ $1 = "-U" ]; then
			read -p "Enter extended commit message: " commitMessage
			git commit -m "Generated by $commitHash" -m "$commitMessage"
		else
			git commit -m "Generated by $commitHash"
		fi
		git push
	fi
fi
