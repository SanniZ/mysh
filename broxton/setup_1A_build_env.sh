#!/bin/bash

# ------------------------------------------------
#  Author: Byng Zeng
#  Date:   2018-11-28
# ------------------------------------------------

#set -x

# Install SSL Certificates
sudo mkdir /usr/share/ca-certificates/intel
sudo wget http://certificates.intel.com/repository/certificates/Intel%20Root%20Certificate%20Chain%20Base64.zip -O /usr/share/ca-certificates/intel/IntelChain.zip
cd /usr/share/ca-certificates/intel/
sudo unzip IntelChain.zip
sudo find -name "* *" -type f | sudo rename 's/ /_/g'
sudo update-ca-certificates
# If it does not work with previous line, try
#sudo dpkg-reconfigure ca-certificates

# Dependencies for Building Android
sudo apt-get install bison g++-multilib git gperf libxml2-utils ccache lib32z1 lib32ncurses5 libbz2-1.0 dos2unix zip unzip make -y
sudo apt-get install imagemagick -y

sudo apt-get install curl -y

# install openjdk8
sudo apt-get install openjdk-8-jdk -y

# install pip
sudo apt install python-pip -y

# install tools
pip install Mako
pip install networkx
sudo apt-get install liblz4-tool -y
# install libs.
sudo apt-get install libssl-dev libxml2-dev gcc-multilib zlib1g-dev -y

