#!/bin/sh
# m52xq: Debian kf6-kirigami 6.30.0-3 + patch: no empty ColumnView slide animation (lost fast taps, found 2026-10-02 on pm-Plasma)
set -e
export LC_ALL=C DEBIAN_FRONTEND=noninteractive DEBFULLNAME="Asdlerto Korry" DEBEMAIL="m52xq@localhost" DEB_BUILD_OPTIONS="nocheck nodoc parallel=16" QUILT_PATCHES=debian/patches
[ -x /native/usr/bin/aarch64-linux-gnu-g++-16 ] && export PATH=/usr/lib/m52xq-cross:$PATH
export PATH=/usr/lib/m52xq-nodwz:$PATH
rm -rf /root/build-kirigami && mkdir -p /root/build-kirigami && cd /root/build-kirigami
apt-get source -q kf6-kirigami=6.30.0-3 > ../build-kirigami-src.log 2>&1
cd kf6-kirigami-6.30.0
cp /root/kirigami-0001-columnview-no-empty-slide-anim.patch debian/patches/m52xq-kirigami-0001-columnview-no-empty-slide-anim.patch
echo m52xq-kirigami-0001-columnview-no-empty-slide-anim.patch >> debian/patches/series
quilt push -a -q >/dev/null
grep -q 'Already in place' src/layouts/columnview.cpp || { echo "PATCH NOT APPLIED"; exit 1; }
echo "patches applied: $(wc -l < .pc/applied-patches)"
dch -v 6.30.0-3+m52xq1 -D unstable "M52XQ: ColumnView: no empty slide animation on every tap (fast taps were lost)" </dev/null
mk-build-deps -i -r -t "apt-get -y --no-install-recommends" debian/control > ../builddeps.log 2>&1 || { echo BUILDDEP FAIL; tail -20 ../builddeps.log; exit 1; }
dpkg-buildpackage -b -uc -us > ../build.log 2>&1 || { echo BUILD FAIL; tail -30 ../build.log; exit 1; }
cd .. && ls *.deb
