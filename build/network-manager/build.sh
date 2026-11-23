#!/bin/sh
# 2026-11-19: network-manager 1.58.1-1+m52xq1 = Debian 1.58.1-1 + m52xq-ignore-suspend.patch (ca5f558f…); parallel=8
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=8"
N=/root/src/nm
echo "===== build-dep network-manager $(date -u +%T)"
apt-get build-dep -y network-manager > $N/build-dep.log 2>&1 || { echo BUILD-DEP-FAILED; tail -15 $N/build-dep.log; exit 10; }
cd $N/src || exit 11
cp ../m52xq-ignore-suspend.patch debian/patches/m52xq-ignore-suspend.patch
grep -qx m52xq-ignore-suspend.patch debian/patches/series || echo m52xq-ignore-suspend.patch >> debian/patches/series
dch -v "1.58.1-1+m52xq1" -D forky "M52XQ: optionally ignore the logind sleep/resume signal (/etc/NetworkManager/m52xq-ignore-suspend): applications saw every phone suspend as a network loss"
echo "===== network-manager $(date -u +%T)"
dpkg-buildpackage -B -us -uc > $N/build.log 2>&1; rc=$?
echo "network-manager rc=$rc $(date -u +%T)"; tail -5 $N/build.log; ls -1 $N/*.deb | grep -v dbgsym
echo ALL-DONE
