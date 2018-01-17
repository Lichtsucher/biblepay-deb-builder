FROM ubuntu:16.04

# install all dependencies
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:bitcoin/bitcoin && \
    apt-get update && \
    apt-get install -y mc libdb4.8-dev libdb4.8++-dev automake debhelper bash-completion libqrencode-dev bsdmainutils \
                       g++ git make build-essential autoconf libtool pkg-config libboost-all-dev libssl-dev libevent-dev \
                       libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools \
                       libprotobuf-dev protobuf-compiler debmake && apt-get clean 

RUN mkdir /code
WORKDIR /code

# /debian will contain the changelog, that is different from the original in contrib/debian
VOLUME /debian

# we need to mount the user gnupg settings, required for signing the package
VOLUME /root/.gnupg

# the run_*_build.sh does the real work
ADD helper/run_ppa_build.sh /code/run_ppa_build.sh
ADD helper/run_local_build.sh /code/run_local_build.sh

# .dput.cf controls the upload script for Launchpads PPA
ADD ppa.conf /root/.dput.cf
