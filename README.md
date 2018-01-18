# Biblepay Ubuntu Package Builder

This project is used to build Ubuntu packages for Biblepay and upload them to Launchpad/PPA.

(PPA is an repository for deb-packages that is hosted by ubuntus launchpad)

## Requirements

You need a linux system (ubuntu or debian is not required) with: 
* bash  (indeed)
* docker

Everything else is installed inside a docker container.

## Preparation

Before you can start with building the package, you must create an PPA on launchpa

**1. Create a GnuPG Key**
Complete howto: https://help.ubuntu.com/community/GnuPrivacyGuardHowto

* Install gnupg
* Run "gpg --gen-key"
* Choose "RSA and RSA (default)"
* Use your real e-mail adress!
* Choose a secure key password
* You will need the Fingerprint, copy it
* Upload the public key with "gpg --send-keys --keyserver keyserver.ubuntu.com [KEY-ID]" (KEY-ID example: "D8FC66D2")
* Do not forget to backup your keys!

**2. Register with launchpad**
* Go to https://launchpad.net
* Register yourself
* Add Fingerprint (Click on your username at the top-right corner, then "Change email settings"). You find the     fingerprint in the output 
* Launchpad will send you an email to ensure that you own the private key of the fingerprint. Copy the Message (starts with "-----BEGIN PGP MESSAGE-----" and ends with "-----END PGP MESSAGE-----" and save it to a file. Decrypt file with "gpg --output [OUTPUTFILENAME] --decrypt [ENCRYPTED FILE]"
* The decryped message will contain a link, open it to verify your ownership of the key 

**3. Register a team at launchpad**
This step is only required if there is not already a team existing. If that is the case, request membership. You can also skip this, if you want to use your own personal ppa.

* Register a team at https://launchpad.net/people/+newteam

**4. Create a PPA**

* Go to your Team page (or personal page) in Launchpad and click "Create a new PPA"
* If this is your first time with Launchpad, you might want to create a test PPA first
* Choose usefull names. Remember that you can not change them later
* IMPORTANT: The biblepay Client required an old Version of the berkeley db that is part of the bitcoin ppa repository. Go to your PPA page and click "Edit PPA dependencies". Search for "bitcoin" and add the "bitcoin/ubuntu/bitcoin" repository as dependency.

## Configuration

All you need todo is copy the file "ppa.conf.USE" as "ppa.conf" and update it:

```
[my-ppa]
fqdn = ppa.launchpad.net
method = ftp
incoming = ~<your_user-or-team-launchpad_id>/ubuntu/<ppa_name>/
login = anonymous
allow_unsigned_uploads = 0
```
Change <your_user-or-team-launchpad_id> and <ppa_name> to your own values.
(This file will be used as dput.cf and copied to /root/ in the docker image)

# Build for ppa

Before you can build a new version, you must update the file "debian/changelog" and add a new entry to the file. Important: Newer entries are at the TOP!

Then this is done, simply call **./ppa_build.sh**. The script will ask you some questions, answer them and the building will start.

**Important:** Only the source code packages are build locally, the real binary packages are build on launchpad. You can see the build status on your launchpad team site. It might take 1-2 hours to build the packages.

# Build binaries locally 

Call **./local_build.sh** and follow the instructions. You will find the packages in the newly created folder "packages"


## Notes

* The scripts will build packages for all ubuntu releases given in "ubuntu_releases". The file MUST end with an empty line!


## Possible problems

* If the build fails, ensure that you added the Dependencies (bitcoint ppa) to your ppa repository!
* If you regenerate the same version again and upload it to PPA, launchpad will refect it. You might try this if you forgot to add the dependencies, but you must change the ubuntu version number (the one after [release]) in the changelog.
