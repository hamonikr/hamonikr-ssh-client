#!/bin/bash

VERSION=`egrep -o 'APPVERSION.*=.*' lib/PACUtils.pm | tr -d '[:space:]' | tr -d "'" | tr -d ";" | tr -d '[APPVERSION=]'`
rm -rf build
mkdir build
cp -r dist/deb/debian build/

tar -cpf "build/asbru-cm_$VERSION.orig.tar" --exclude ".git" --exclude "debian" --exclude "build" --exclude "dist" .

cd build
tar -xf asbru-cm_$VERSION.orig.tar
xz -9 asbru-cm_$VERSION.orig.tar

mv asbru-cm_$VERSION.orig.tar.xz ../

dpkg-buildpackage --sign-key=9FA298A1E42665B8

dpkg-buildpackage -T clean

cd ..
rm -rf release
mkdir release
mv *.{deb,tar.xz,dsc,changes,buildinfo} ../
rm -f asbru-cm_$VERSION.orig.tar.xz

# ls -lha ./release/

echo "All done. Hopefully"                   
