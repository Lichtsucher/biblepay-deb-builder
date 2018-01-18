# we remove all old files that might exist
rm -rf /code/*

# we clone of the biblepay sourcecode here
#git clone https://github.com/biblepay/biblepay biblepay
git clone https://github.com/Lichtsucher/biblepay

cd /code/biblepay

# we build the "orignal source" from the cloned git repository (excluding the git files)
tar cfj ../biblepay_$VERSIONSTR.orig.tar.bz2 . --exclude-vcs

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
debuild

# we now copy the finished files to the packages volume that is a directory of the host system
cp /code/*.deb /packages/
