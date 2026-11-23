#!/bin/sh
# 2026-11-19: gnome-snapshot 51.0-2+m52xq1 = Debian 51.0-2 + pmOS Phosh v1 patch m52xq-0001-r127 (5c1beda0…); parallel=8
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=8"
C=/root/src/cam
echo "===== build-dep gnome-snapshot $(date -u +%T)"
apt-get build-dep -y gnome-snapshot > $C/build-dep-snapshot.log 2>&1 || { echo BUILD-DEP-FAILED; tail -15 $C/build-dep-snapshot.log; exit 10; }
echo "===== snapshot $(date -u +%T)"
cd $C/snap/src || exit 11
cp $C/r2-snap/m52xq-0001-r127.patch debian/patches/m52xq-0001-r127.patch
grep -qx m52xq-0001-r127.patch debian/patches/series || echo m52xq-0001-r127.patch >> debian/patches/series
dch -v "51.0-2+m52xq1" -D forky "M52XQ: pmOS Phosh v1 Snapshot patch r127 (rotation, front camera, pinch zoom, tap focus, gallery zoom, 64/32 MP photos via m52xq-rawphoto, Venus video, 4K, viewfinder fixes)"
dpkg-buildpackage -B -us -uc > $C/build-snapshot.log 2>&1; rc=$?
echo "snapshot rc=$rc $(date -u +%T)"; tail -5 $C/build-snapshot.log; ls -1 $C/snap/*.deb
echo ALL-DONE
