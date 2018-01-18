# we remove all old files that might exist
rm -rf /code/*

# launchpad hates it when the same *.orig"-File was created two times
# with slightly differen time stamps. So we only create one, if that is
# really necessary

if [ ! -f /packages/ppa_orig/biblepay_$VERSIONSTR.orig.tar.bz2 ]; then
  # file not found

  echo "No existing orig-file found, clone from git"

  # we clone of the biblepay sourcecode here
  #git clone https://github.com/biblepay/biblepay biblepay
  git clone https://github.com/Lichtsucher/biblepay

  # we build the "orignal source" from the cloned git repository (excluding the git files)
  cd /code/biblepay
  tar cfj ../biblepay_$VERSIONSTR.orig.tar.bz2 . --exclude-vcs
  cp ../biblepay_$VERSIONSTR.orig.tar.bz2 /packages/ppa_orig/
else
  # found

  echo "Existing orig-file found. Use it"

  cp /packages/ppa_orig/biblepay_$VERSIONSTR.orig.tar.bz2 /code/

  mkdir biblepay
  cd /code/biblepay
  tar -jxf ../biblepay_$VERSIONSTR.orig.tar.bz2
fi

# the debian folder must be in debian/ not contrib/debian, so we must move it
cp -rf contrib/debian .

# here we overwrite or add files to the debian folder
cp -rf /debian/* ./debian/

# update the changelog and replace [release] with $RELEASENAME
mv debian/changelog debian/changelog_org
sed "s/\[release\]/$RELEASENAME/g" debian/changelog_org > debian/changelog

# ensure that important files are executable
chmod 777 share/genbuild.sh
chmod 777 autogen.sh 

# create and sign the required debian source files
debuild -S -sa

# after the source files are finished, we upload them to ppa
# the name "biblepay" in dput" is a reference to the section [biblepay] in the ppa.conf
cd /code/
dput biblepay *_source.changes

# we also copy all created files to our packages directory
cp /code/* /packages/
