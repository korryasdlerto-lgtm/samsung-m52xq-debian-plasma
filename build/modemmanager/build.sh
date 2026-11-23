#!/bin/sh
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck parallel=16"
cd /root/src
apt-get -y build-dep modemmanager || exit 11
[ -d modemmanager-1.24.2 ] || apt-get source modemmanager || exit 12
cd /root/src/modemmanager-1.24.2/ && rm -f debian/patches/0100* debian/patches/0101* debian/patches/0102* debian/patches/0103* debian/patches/0104* debian/patches/0105* debian/patches/0106* && cd /root/src
cd modemmanager-*/ || exit 13
# the patches are applied in order by quilt (dpkg-buildpackage); each one depends on the previous (a separate dry-run of 0101/0102 fails)
mkdir -p debian/patches; : > debian/patches/series.new; for p in /root/src/m52xq-mm-patches/*.patch; do cp "$p" debian/patches/; echo "$(basename $p)" >> debian/patches/series; done
dch -v "$(dpkg-parsechangelog -S Version)+m52xq1" -D forky "M52XQ patches: dual SIM (DSDS) on QRTR"
dpkg-buildpackage -b -us -uc
