#!/usr/bin/env bash

# get the absolute path to this script. Required to mount the "packages" directory
BASEDIR="$( cd "$(dirname "$0")" ; pwd -P )"

# And dates as version numbers '"
CURRENT_DATE=`LC_ALL=en_US date '+%Y%m%d%H%M%S'`
CURRENT_DATE_NICE=`LC_ALL=en_US date '+%a, %d %b %Y %H:%M:00 +0100'`


# First, we update the repository and get the current (and last) version
# You must download this repository by yourself before you can use the script
cd bbp_nightly_repository
git pull origin master
cd ..

CURRENT_VERSION=`cd bbp_nightly_repository && git rev-parse HEAD`
echo $CURRENT_VERSION

touch last_nightly_commit.data
LAST_VERSION=`cat last_nightly_commit.data`

# Is the current newest commit different fromt last one?
# If not, then exit
if [ "$CURRENT_VERSION" == "$LAST_VERSION" ]; then
   echo "No change found. Exit"
   exit
fi


# write the changelog
# We save the old one
cp debian/changelog debian/changelog.save

echo "biblepay ($CURRENT_DATE-[release]1) [release]; urgency=low" > debian/changelog
echo "  * New upstream release" >> debian/changelog
echo -n " -- Lichtsucher <lichtsucher@maxolero.net>  $CURRENT_DATE_NICE" >> debian/changelog

# output directory for the deb-files
/bin/mkdir -p $BASEDIR/packages/ppa_orig

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
  docker run -i -e RELEASENAME="$RELEASENAME" -e RELEASEVERSION="$RELEASEVERSION" -e VERSIONSTR="$CURRENT_DATE" -v $BASEDIR/packages:/packages -v $HOME/.gnupg:/root/.gnupg -v $BASEDIR/debian:/debian "debpackage-$RELEASENAME" /bin/sh /code/run_ppa_build.sh

  # cleanup
  rm -f Dockerfile
done



# Cleanup and version saving

echo -n "$CURRENT_VERSION" > last_nightly_commit.data
cp debian/changelog.save debian/changelog

