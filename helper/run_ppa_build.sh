# we remove all old files that might exist
rm -rf /code/*

# we clone of the biblepay sourcecode here
#git clone https://github.com/biblepay/biblepay biblepay
git clone https://github.com/Lichtsucher/biblepay

cd /code/biblepay

# the debian folder must be in debian/ not contrib/debian, so we must move it
mv contrib/debian .

# here we overwrite or add files to the debian folder
cp -rf /debian/* ./debian/

# ensure that important files are executable
chmod 777 share/genbuild.sh
chmod 777 autogen.sh 

# we build the "orignal source" from the cloned git repository (excluding the git files)
tar cfj ../biblepay_$VERSIONSTR.orig.tar.bz2 . --exclude-vcs

# create and sign the required debian source files
debuild -S -sa

# after the source files are finished, we upload them to ppa
cd /code/
dput ppa:lichtsucher/bbptest1 *_source.changes
