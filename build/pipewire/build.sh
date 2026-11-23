#!/bin/sh
# 2026-11-19: camera step 2 — libcamera 0.8.0 into the build chroot, then PipeWire 1.6.9-2+m52xq1 against it (parallel=8: the PC hung once with 16)
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=8"
C=/root/src/cam
echo "===== install libcamera 0.8 into the build chroot $(date -u +%T)"
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
