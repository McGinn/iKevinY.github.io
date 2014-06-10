#!/usr/bin/env bash
# Derived from http://zonca.github.io/2013/09/automatically-build-pelican-and-publish-to-github-pages.html

BRANCH=master
TARGET_REPO=iKevinY/iKevinY.github.io.git
PELICAN_OUTPUT_FOLDER=output
REMOTE_OUTPUT_FOLDER=remote-site

if [ "$TRAVIS" == "true" ]; then
	echo -e "Deploying site to GitHub Pages via Travis CI.\n"
	git config --global user.email "travis@travis-ci.org"
	git config --global user.name "Travis CI"
else
	# If being run locally, site files need to be generated
	pelican -s publishconf.py
fi

# Pull hash and commit message of most recent commit
commitHash=`git rev-parse HEAD`
commitMessage=`git log -1 --pretty=%B`

# Clone and sync newly generated site files
if [ "$TRAVIS" == "true" ]; then
	GITHUB_REPO=https://${GH_TOKEN}@github.com/$TARGET_REPO
else
	GITHUB_REPO=https://git@github.com/$TARGET_REPO
fi

git clone --quiet --branch=$BRANCH $GITHUB_REPO $REMOTE_OUTPUT_FOLDER > /dev/null
cd $REMOTE_OUTPUT_FOLDER
rsync -qrv --exclude=.git --delete ../$PELICAN_OUTPUT_FOLDER/ ./

if [ "$TRAVIS" == "false" ]; then
	rm -rf ../output
fi

# Add, commit, and push files
if [ "$TRAVIS" == "true" ]; then
	git add -A
	git status -s
	git commit -m "$commitMessage" -m "Generated by commit $commitHash; pushed by Travis build $TRAVIS_BUILD_NUMBER."
	git push -fq origin $BRANCH > /dev/null
	echo -e "Deploy completed.\n"
else
	git add -A
	git checkout master

	printf "Last commit: \e[1;37m$commitMessage\e[0m\n"
	read -p "Upload site files? [y/N] " response
	printf "\n"

	case $response in
		[yY])
			git commit -m "$commitMessage" -m "Generated by commit $commitHash"
			git push
			;;
		*)
			echo "Cancelling commit."
			;;
	esac

	cd ..
	rm -rf $REMOTE_OUTPUT_FOLDER
	rm -rf output
	if [[ $response != "y" ]] && [[ $response != "Y" ]]; then
		exit 1
	fi
fi
