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


# output directory for the deb-files
# The ppa_orig directory saves the old ppa files, so that we do not change them between uploads
mkdir -p $BASEDIR/packages/


# read the ubuntu version from the file and put it into an array
# we need to have an own step here, or the loop would stop the tty, which we need for docker
while read release; do
  releases+=("$release")
done < ubuntu_releases

# build a version of the package for every given ubuntu release
for line in "${releases[@]}"; do
  # nice trick that splits the string "xenial|16.04" into "xenial" and "16.04"
  RELEASENAME=${line%|*}
  RELEASEVERSION=${line#*|}

  echo "Build package for $RELEASENAME / $RELEASEVERSION"

  # create a temp folder and place a release-specific Dockerfile there
  sed 's/\[releaseversion\]/16.04/g' Dockerfile.tpl  > Dockerfile

  # build the docker image, won't execute any code
  docker build -t "debpackage-$RELEASENAME" .

  # start the docker image with some required volumes and starts the build process itselfs
  # we do one buildprocess per ubuntu version
  docker run -it -e RELEASENAME="$RELEASENAME" -e RELEASEVERSION="$RELEASEVERSION" -e VERSIONSTR="$VERSIONSTR" -v $BASEDIR/packages:/packages -v $HOME/.gnupg:/root/.gnupg -v $BASEDIR/debian:/debian "debpackage-$RELEASENAME" /bin/sh /code/run_local_build.sh

  # cleanup
  rm -f Dockerfile
done





