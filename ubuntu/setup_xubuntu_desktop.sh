#!/bin/bash

# ===========================================
#    Config ubuntu rxdp for remote desktop
# ===========================================
# --------------------------
# author: Byng Zeng
# Date  : 2018-11-30
# --------------------------

# install xrdp
sudo apt-get install xrdp -y

# install xubuntu-desktop
sudo apt-get install xubuntu-desktop -y

# config .xsession
echo "xfce4-session" > ~/.xsession

# config xfce startwm
echo '#!/bin/sh' >> temp.txt
echo '' >> temp.txt
echo 'if [ -r /etc/default/locale ]; then' >> temp.txt
echo '  . /etc/default/locale' >> temp.txt
echo '  export LANG LANGUAGE' >> temp.txt
echo 'fi' >> temp.txt
echo '' >> temp.txt
echo 'xfce4-session' >> temp.txt
echo '. /etc/X11/Xsession' >> temp.txt
sudo cp temp.txt /etc/xrdp/startwm.sh
sudo chmod 0755 /etc/xrdp/startwm.sh
# remove temp txt.
rm temp.txt

# restart xrdp
sudo service xrdp restart
