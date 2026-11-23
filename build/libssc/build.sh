#!/bin/sh
# libssc 0.4.4 for Debian: not packaged in Debian; two variants as on postmarketOS:
#  - system library with patch 0002 (unknown proximity states are logged and skipped instead of aborting iio-sensor-proxy),
#  - /usr/lib/m52xq/libssc.so.2 with patch 0003 (also dumps every proximity report: raw distance for m52xq-incall-proximity).
set -e
export DEBIAN_FRONTEND=noninteractive LC_ALL=C
apt-get -y --no-install-recommends install build-essential meson ninja-build pkg-config libudev-dev libglib2.0-dev libgudev-1.0-dev libqmi-glib-dev libprotobuf-c-dev protobuf-c-compiler protobuf-compiler python3-dev python3-gi python3-protobuf libqrtr-glib-dev libqrtr-dev
cd /root/src/libssc
for v in 0002 0003; do
  rm -rf src-$v dest-$v && mkdir src-$v dest-$v
  tar -xzf libssc-0.4.4.tar.gz -C src-$v --strip-components=1
  pf=$(ls /root/src/libssc/libssc-m52xq-$v-*.patch)
  ( cd src-$v && patch -p1 < "$pf" )
  ( cd src-$v && meson setup build --prefix=/usr --buildtype=release && meson compile -C build && DESTDIR=/root/src/libssc/dest-$v meson install -C build )
done
# one package: the 0002 variant in the system paths + the 0003 library in /usr/lib/m52xq
PKG=/root/src/libssc/pkg; rm -rf $PKG; cp -a dest-0002 $PKG
mkdir -p $PKG/usr/lib/m52xq
cp -a $(find dest-0003 -name 'libssc.so.2*' | sort | tail -1) $PKG/usr/lib/m52xq/libssc.so.2
mkdir -p $PKG/DEBIAN
cat > $PKG/DEBIAN/control <<C
Package: libssc-m52xq
Version: 0.4.4-0m52xq1
Architecture: arm64
Maintainer: Asdlerto Korry <korryasdlerto@gmail.com>
Depends: libglib2.0-0t64, libgudev-1.0-0, libqmi-glib5, libprotobuf-c1, libqrtr-glib0
Description: Qualcomm Sensor Core client library (libssc 0.4.4) for the Samsung Galaxy M52 (m52xq)
 System library with the m52xq patch 0002 and /usr/lib/m52xq/libssc.so.2 with patch 0003 (proximity report dump).
C
dpkg-deb --build --root-owner-group $PKG /root/src/libssc-m52xq_0.4.4-0m52xq1_arm64.deb
find $PKG -type f | sed "s#$PKG##" | grep -v DEBIAN | head -20
