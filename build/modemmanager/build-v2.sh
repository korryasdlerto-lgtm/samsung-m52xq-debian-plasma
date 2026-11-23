#!/bin/sh
# 2026-11-20: modemmanager 1.24.2-2+m52xq2 = +m52xq1 (0100–0106) + 0107 (count bearers incl. multiplexed: no ABRT on suspend with mobile data); parallel=8
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=8"
cd /root/src/modemmanager-1.24.2 || exit 1
dch -v "1.24.2-2+m52xq2" -D forky "M52XQ: 0107 count multiplexed bearers in the ACTIVE/CONNECTED maximum (backport from 1.25): ModemManager aborted on suspend with mobile data on (IPA)"
( cd obj-aarch64-linux-gnu && meson configure -Dgtk_doc=false ) || exit 2
echo "start $(date -u +%T)"
dpkg-buildpackage -B -us -uc -nc; rc=$?
echo "rc=$rc end $(date -u +%T)"; ls -l /root/src/*1.24.2-2+m52xq2*.deb 2>/dev/null
exit $rc
