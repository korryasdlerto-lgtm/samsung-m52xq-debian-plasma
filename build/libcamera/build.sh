#!/bin/sh
# 2026-11-19: camera as in pmOS Phosh v1, step 1: libcamera 0.8.0 (+ our 6 patches, libcamera0.8), then PipeWire 1.6.9 rebuilt against it.
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=16"
C=/root/src/cam
echo "===== build-dep libcamera $(date -u +%T)"
apt-get build-dep -y libcamera > $C/build-dep-libcamera.log 2>&1 || { echo BUILD-DEP-LIBCAMERA-FAILED; tail -15 $C/build-dep-libcamera.log; exit 10; }
echo "===== libcamera 0.8.0 $(date -u +%T)"
cd $C/libcamera-0.8.0 || exit 11
dpkg-buildpackage -B -us -uc > $C/build-libcamera.log 2>&1; rc=$?
echo "libcamera rc=$rc $(date -u +%T)"; tail -5 $C/build-libcamera.log; ls -1 $C/*0.8.0-0m52xq1*.deb
[ $rc = 0 ] || exit 12
echo "===== install libcamera 0.8 dev into the build chroot $(date -u +%T)"
cd $C && apt-get install -y ./libcamera0.8_0.8.0-0m52xq1_arm64.deb ./libcamera-dev_0.8.0-0m52xq1_arm64.deb ./libcamera-ipa_0.8.0-0m52xq1_arm64.deb > $C/install-libcamera-dev.log 2>&1 || { echo INSTALL-DEV-FAILED; tail -20 $C/install-libcamera-dev.log; exit 13; }
pkg-config --modversion libcamera
echo "===== build-dep pipewire $(date -u +%T)"
apt-get build-dep -y pipewire > $C/build-dep-pipewire.log 2>&1 || { echo BUILD-DEP-PIPEWIRE-FAILED; tail -15 $C/build-dep-pipewire.log; exit 14; }
pkg-config --modversion libcamera
echo "===== pipewire 1.6.9-2+m52xq1 $(date -u +%T)"
rm -rf $C/pw && mkdir -p $C/pw && cd $C/pw && cp ../pipewire_1.6.9-2.dsc ../pipewire_1.6.9-2.debian.tar.xz ../pipewire_1.6.9.orig.tar.gz . && dpkg-source -x pipewire_1.6.9-2.dsc src > /dev/null || exit 15
cd src && dch -v "1.6.9-2+m52xq1" -D forky "M52XQ: rebuilt against libcamera 0.8.0 (libcamera0.8, postmarketOS Phosh v1 camera stack)"
dpkg-buildpackage -B -us -uc > $C/build-pipewire.log 2>&1; rc=$?
echo "pipewire rc=$rc $(date -u +%T)"; tail -5 $C/build-pipewire.log; ls -1 $C/pw/*.deb
echo ALL-DONE
