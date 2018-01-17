# Biblepay Ubuntu Package Builder

This project is used to build Ubuntu packages for Biblepay and upload them to Launchpad/PPA.

(PPA is an repository for deb-packages that is hosted by ubuntus launchpad)

## Requirements

You need a linux system (ubuntu or debian is not required) with bash and docker.
Everything else is installed inside a docker container.

## Preparation

Before you can start with building the package, you must create an PPA on launchpa

**1. Create a GnuPG Key**
Complete howto: https://help.ubuntu.com/community/GnuPrivacyGuardHowto

1.1. Install gnupg
1.2. Run "gpg --gen-key"
1.3. Choose "RSA and RSA (default)"
1.4. Use your real e-mail adress!
1.5. Choose a secure key password
1.6. You will need the Fingerprint, copy it
1.7. Upload the public key with "gpg --send-keys --keyserver keyserver.ubuntu.com [KEY-ID]" (KEY-ID example: "D8FC66D2")
1.8. Do not forget to backup your keys!

**2. Register with launchpad**
2.1. Go to https://launchpad.net
2.2. Register yourself
2.3. Add Fingerprint (Click on your username at the top-right corner, then "Change email settings"). You find the     fingerprint in the output 
2.4. Launchpad will send you an email to ensure that you own the private key of the fingerprint. Copy the Message (starts with "-----BEGIN PGP MESSAGE-----" and ends with "-----END PGP MESSAGE-----" and save it to a file. Decrypt file with "gpg --output [OUTPUTFILENAME] --decrypt [ENCRYPTED FILE]"
2.5 The decryped message will contain a link, open it to verify your ownership of the key 

**3. Register a team at launchpad**
This step is only required if there is not already a team existing. If that is the case, request membership.

3.1 Register a team at https://launchpad.net/people/+newteam

## Configuration

All you need todo is copy the file "ppa.conf.USE" as "ppa.conf" and update it:

[my-ppa]
fqdn = ppa.launchpad.net
method = ftp
incoming = ~<your_user-or-team-launchpad_id>/ubuntu/<ppa_name>/
login = anonymous
allow_unsigned_uploads = 0

Change <your_user-or-team-launchpad_id> and <ppa_name> to your own values.

# Build for ppa

Before you can build a new version, you must update the file "debian/changelog" and add a new entry to the file. Important: Newer entries are at the TOP!
Then this is done, simply call **./ppa_build.sh**. The script will ask you some questions, answer them and the building will start.
Important: Only the source code packages are build locally, the real binary packages are build on launchpad. You can see the build status on your launchpad team site. It might take 1-2 hours to build the packages.

# Build binaries locally 

Call **./local_build.sh** and follow the instructions. You will find the packages in the newly created folder "packages"