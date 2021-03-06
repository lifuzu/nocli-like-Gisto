#!/bin/bash

### Depends on fakeroot, alien, node-webkit, build-essential, dh-make, debhelper, devscripts

HERE=`pwd`
ME=`whoami`
APP_DIR="/home/$ME/www/gisto/app"

cd ../

echo -e "\n\n\n"


### Run grunt
echo -e "\e[30;48;5;82m >>> \e[40;38;5;82m Run grunt against the project \e[0m"
grunt --debug

read -e -p "Please enter you name: " -i "Sasha Khamkov" NAME
read -e -p "Please enter your e-mail address: " -i "sanusart@gmail.com" EMAIL
read -e -p "Please enter version number: " -i "0.1.0a" VERSION
read -e -p "Please enter architecture [amd64, i386, any]: " -i "amd64" ARCH
read -e -p "Please enter package name: " -i "gisto-$VERSION-$ARCH" PKG_NAME

sed -i "s/%NAME%/$NAME/g" $HERE/gisto/DEBIAN/control
sed -i "s/%EMAIL%/$EMAIL/g" $HERE/gisto/DEBIAN/control
sed -i "s/%ARCH%/$ARCH/g" $HERE/gisto/DEBIAN/control
sed -i "s/%VERSION%/$VERSION/g" $HERE/gisto/DEBIAN/control

echo -e "\e[30;48;5;82m >>> \e[40;38;5;82m Creating binaries with node-webkit \e[0m"
cd $APP_DIR && zip -r app.nw *


cat /usr/bin/nw app.nw > gisto && chmod +x gisto
mv gisto $HERE/gisto/usr/bin/

echo -e "\e[30;48;5;82m >>> \e[40;38;5;82m Creating .deb file \e[0m"
dpkg -b $HERE/gisto


if [ ! -d ../bin/$VERSION ]
then
	mkdir ../bin/$VERSION
fi

mv $HERE/gisto.deb ../bin/$VERSION/$PKG_NAME.deb

### Create .RPM via alien
echo -e "\e[30;48;5;82m >>> \e[40;38;5;82m Create .RPM file with 'alien' \e[0m"
fakeroot alien --to-rpm -c -k ../bin/$VERSION/$PKG_NAME.deb
mv gisto-*.rpm ../bin/$VERSION/$PKG_NAME.rpm

### Create binaries
echo -e "\e[30;48;5;82m >>> \e[40;38;5;82m Create tar.gz file \e[0m"
cd $HERE/gisto
tar -cvzf $PKG_NAME.tar.gz usr
mv $PKG_NAME.tar.gz ../../../bin/$VERSION/

echo -e "\e[30;48;5;82m >>> \e[40;38;5;82m Clean-up.... \e[0m"

sed -i "s/$NAME/%NAME%/g" $HERE/gisto/DEBIAN/control
sed -i "s/$EMAIL/%EMAIL%/g" $HERE/gisto/DEBIAN/control
sed -i "s/$ARCH/%ARCH%/g" $HERE/gisto/DEBIAN/control
sed -i "s/$VERSION/%VERSION%/g" $HERE/gisto/DEBIAN/control

rm $APP_DIR/app.nw
rm $HERE/gisto/usr/bin/gisto

