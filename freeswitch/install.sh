#!/bin/bash

# FreeSWITCH Installation script for CentOS 5.5/5.6
# and Debian based distros (Debian 5.0 , Ubuntu 10.04 and above)
# Copyright (c) 2011 Plivo Team. See LICENSE for details.


FS_CONF_PATH=https://github.com/plivo/plivo/raw/master/freeswitch/conf
FS_GIT_REPO=git://git.freeswitch.org/freeswitch.git
FS_INSTALLED_PATH=/usr/local/freeswitch

#####################################################
FS_BASE_PATH=/usr/src/
#####################################################

CURRENT_PATH=$PWD

# Identify Linux Distribution
if [ -f /etc/debian_version ] ; then
        DIST="DEBIAN"
elif [ -f /etc/redhat-release ] ; then
        DIST="CENTOS"
else
    echo ""
    echo "This Installer should be run on a CentOS or a Debian based system"
    echo ""
    exit 1
fi


clear
echo ""
echo "FreeSWITCH will be installed in $FS_INSTALLED_PATH"
echo "Press any key to continue or CTRL-C to exit"
echo ""
read INPUT


echo "Setting up Prerequisites and Dependencies for FreeSWITCH"
case $DIST in
        'DEBIAN')
            apt-get -y update
            apt-get -y upgrade
            apt-get -y install autoconf automake autotools-dev binutils bison build-essential cpp curl flex g++ gcc git-core libaudiofile-dev libc6-dev libdb-dev libexpat1 libgdbm-dev libgnutls-dev libmcrypt-dev libncurses5-dev libnewt-dev libpcre3 libpopt-dev libsctp-dev libsqlite3-dev libtiff4 libtiff4-dev libtool libx11-dev libxml2 libxml2-dev lksctp-tools lynx m4 make mcrypt ncftp nmap openssl sox sqlite3 ssl-cert ssl-cert unixodbc-dev unzip zip zlib1g-dev zlib1g-dev

        ;;
        'CENTOS')
            yum -y update
            yum -y install autoconf automake bzip2 cpio curl curl-devel curl-devel expat-devel fileutils gcc-c++ gettext-devel git-core gnutls-devel libjpeg-devel libogg-devel libtiff-devel libtool libvorbis-devel make ncurses-devel nmap openssl openssl-devel openssl-devel perl unixODBC unixODBC-devel unzip wget zip zlib zlib-devel

        ;;
esac

# Install FreeSWITCH
cd $FS_BASE_PATH
git clone $FS_GIT_REPO
cd $FS_BASE_PATH/freeswitch
sh bootstrap.sh && ./configure
[ -f modules.conf ] && cp modules.conf modules.conf.bak
sed -i "s/#applications\/mod_curl/applications\/mod_curl/g" modules.conf
sed -i "s/#asr_tts\/mod_flite/asr_tts\/mod_flite/g" modules.conf
sed -i "s/#asr_tts\/mod_tts_commandline/asr_tts\/mod_tts_commandline/g" modules.conf
sed -i "s/#formats\/mod_shout/formats\/mod_shout/g" modules.conf
sed -i "s/#endpoints\/mod_dingaling/endpoints\/mod_dingaling/g" modules.conf
sed -i "s/#formats\/mod_shell_stream/formats\/mod_shell_stream/g" modules.conf
sed -i "s/#say\/mod_say_de/say\/mod_say_de/g" modules.conf
sed -i "s/#say\/mod_say_es/say\/mod_say_es/g" modules.conf
sed -i "s/#say\/mod_say_fr/say\/mod_say_fr/g" modules.conf
sed -i "s/#say\/mod_say_it/say\/mod_say_it/g" modules.conf
sed -i "s/#say\/mod_say_nl/say\/mod_say_nl/g" modules.conf
sed -i "s/#say\/mod_say_ru/say\/mod_say_ru/g" modules.conf
sed -i "s/#say\/mod_say_zh/say\/mod_say_zh/g" modules.conf
sed -i "s/#say\/mod_say_hu/say\/mod_say_hu/g" modules.conf
sed -i "s/#say\/mod_say_th/say\/mod_say_th/g" modules.conf
make && make install && make sounds-install && make moh-install

# Enable FreeSWITCH modules
cd $FS_INSTALLED_PATH/conf/autoload_configs/
[ -f modules.conf.xml ] && cp modules.conf.xml modules.conf.xml.bak
sed -i "s/<\!-- <load module=\"mod_xml_curl\"\/> -->/<load module=\"mod_xml_curl\"\/>/g" modules.conf.xml
sed -i "s/<\!-- <load module=\"mod_xml_cdr\"\/> -->/<load module=\"mod_xml_cdr\"\/>/g" modules.conf.xml
sed -i "s/<\!-- <load module=\"mod_dingaling\"\/> -->/<load module=\"mod_dingaling\"\/>/g" modules.conf.xml
sed -i "s/<\!-- <load module=\"mod_shout\"\/> -->/<load module=\"mod_shout\"\/>/g" modules.conf.xml
sed -i "s/<\!--<load module=\"mod_shout\"\/>-->/<load module=\"mod_shout\"\/>/g" modules.conf.xml
sed -i "s/<\!--<load module=\"mod_tts_commandline\"\/>-->/<load module=\"mod_tts_commandline\"\/>/g" modules.conf.xml
sed -i "s/<\!-- <load module=\"mod_flite\"\/> -->/<load module=\"mod_flite\"\/>/g" modules.conf.xml
sed -i "s/<\!-- <load module=\"mod_say_ru\"\/> -->/<load module=\"mod_say_ru\"\/>/g" modules.conf.xml
sed -i "s/<\!-- <load module=\"mod_say_zh\"\/> -->/<load module=\"mod_say_zh\"\/>/g" modules.conf.xml
sed -i 's/mod_say_zh.*$/&\n    <load module="mod_say_de"\/>\n    <load module="mod_say_es"\/>\n    <load module="mod_say_fr"\/>\n    <load module="mod_say_it"\/>\n    <load module="mod_say_nl"\/>\n    <load module="mod_say_hu"\/>\n    <load module="mod_say_th"\/>/' modules.conf.xml


#Configure Dialplan
cd $FS_INSTALLED_PATH/conf/dialplan/

# Place Plivo Default Dialplan in FreeSWITCH
[ -f default.xml ] && mv default.xml default.xml.bak
wget --no-check-certificate $FS_CONF_PATH/default.xml -O default.xml

# Place Plivo Public Dialplan in FreeSWITCH
[ -f public.xml ] && mv public.xml public.xml.bak

PLIVO_PUBLIC_XML='\n'
PLIVO_PUBLIC_XML+="    <!--"
PLIVO_PUBLIC_XML+="     This extension allows calling any digits of number"
PLIVO_PUBLIC_XML+="     freeswitch will call plivo outbound server on every incoming call"
PLIVO_PUBLIC_XML+="    -->"
PLIVO_PUBLIC_XML+="    <extension name=\"plivo_public_did\">"
PLIVO_PUBLIC_XML+="        <condition field=\"destination_number\" expression=>"
PLIVO_PUBLIC_XML+="            <action application=\"socket\" data=\"127.0.0.1:8084 async full\"/>"
PLIVO_PUBLIC_XML+="        </condition>"
PLIVO_PUBLIC_XML+="    </extension>"
PLIVO_PUBLIC_XML+="    "

sed -i "s/<\/context>*$/$PLIVO_PUBLIC_XML &/" public.xml

cd $CURRENT_PATH

# Install Complete
#clear
echo ""
echo ""
echo ""
echo "**************************************************************"
echo "Congratulations, FreeSWITCH is now installed at '$FS_INSTALLED_PATH'"
echo "**************************************************************"
echo
echo "* To Start FreeSWITCH in foreground :"
echo "    '.$FS_INSTALLED_PATH/bin/freeswitch'"
echo
echo "* To Start FreeSWITCH in background :"
echo "    '.$FS_INSTALLED_PATH/bin/freeswitch -nc'"
echo
echo "**************************************************************"
echo ""
echo ""
exit 0
