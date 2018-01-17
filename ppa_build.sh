#!/usr/bin/env bash

# get the absolute path to this script. Required to mount the "packages" directory
BASEDIR="$( cd "$(dirname "$0")" ; pwd -P )"

# ensure that the changelog is ok

echo ""
echo "Before you start, ensure that you updated debian/changelog! Here are the first 20 lines:"
echo ""

head -n 20 debian/changelog

while true; do
    echo ""
    echo ""
    read -p "Is the changelog correct? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer [y]es or [n]o.";;
    esac
done



# request the version number

echo "Please enter the Biblepay version string off the new release (like: 1.8.0.1). Do NOT add the DEB-Subversion (-1, like 1.8.0.1-1)"

read VERSIONSTR

echo "Entered $VERSIONSTR"

# final check

while true; do
    echo ""
    echo ""
    read -p "The script will now start the docker image, pull the current HEAD and build it as biblepay version $VERSIONSTR. Ok? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer [y]es or [n]o.";;
    esac
done

# build the docker image, won't execute any code
docker build -t debpackage .

# start the docker image with some required volumes and starts the build process itsels
docker run -it -e VERSIONSTR="$VERSIONSTR" -v $HOME/.gnupg:/root/.gnupg -v $BASEDIR/debian:/debian  debpackage /bin/sh /code/run_ppa_build.sh
