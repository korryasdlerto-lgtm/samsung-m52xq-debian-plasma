#!/bin/sh
# M52XQ: build one Plasma module 6.8.3 with the Debian 6.7.4 packaging (runs inside rootfs-plasma, as root)
# usage: build-mod.sh <source-package>
set -e
M=$1; V=6.8.3; S=/root/src; B=/root/build/$M
# m52xq crossdirect: /usr/lib/m52xq-cross wrappers run the x86_64 cross GCC 16.2 from /native (bind mount of native-amd64)
[ -x /native/usr/bin/aarch64-linux-gnu-g++-16 ] && export PATH=/usr/lib/m52xq-cross:$PATH
# m52xq: no dwz (20+ min per package under qemu)
export PATH=/usr/lib/m52xq-nodwz:$PATH
export DEBFULLNAME="Asdlerto Korry" DEBEMAIL="m52xq@localhost" LC_ALL=C DEBIAN_FRONTEND=noninteractive DEB_BUILD_OPTIONS="nocheck nodoc parallel=16" DPKG_GENSYMBOLS_CHECK_LEVEL=0 QUILT_PATCHES=debian/patches
rm -rf $B; mkdir -p $B; cd $B
cp /root/up/$M-$V.tar.xz ${M}_$V.orig.tar.xz
tar -xJf ${M}_$V.orig.tar.xz
# m52xq: the KDE tarball name may differ from the Debian source name (union-6.8.3 -> plasma-union)
[ -d $M-$V ] || mv "$(tar -tJf ${M}_$V.orig.tar.xz | head -1 | cut -d/ -f1)" $M-$V
cd $M-$V
tar -xJf $(ls $S/${M}_*.debian.tar.xz | head -1)
# m52xq: per-module packaging fixes for 6.8 (new files etc.), kept in /root/fixups/<module>.sh
[ -f /root/fixups/$M.sh ] && { echo "fixup: $M"; sh -e /root/fixups/$M.sh; }
old=$(dpkg-parsechangelog -S Version); ep=$(echo "$old" | grep -o '^[0-9]*:' || true)
dch -b --force-distribution -v "${ep}${V}-0m52xq${M52XQ_REV:-1}" -D unstable "M52XQ: new upstream release $V (Plasma 6.8.3 from download.kde.org on the Debian $old packaging)" </dev/null >/dev/null 2>&1
if [ -s debian/patches/series ]; then
  # m52xq: drop every Debian patch that does not apply to 6.8.3 (mostly upstream fixes already in the tarball);
  # quilt next prints debian/patches/<name>, the series file has <name>
  n=0
  while [ $n -lt 30 ]; do
    while quilt push -q >/dev/null 2>&1; do :; done
    nxt=$(quilt next 2>/dev/null | sed 's|^debian/patches/||')
    [ -n "$nxt" ] || break
    echo "PATCH FAIL: $nxt (dropped)"
    grep -vxF "$nxt" debian/patches/series > debian/patches/series.m52xq; mv debian/patches/series.m52xq debian/patches/series
    n=$((n+1))
  done
  quilt pop -a -q >/dev/null 2>&1 || true
fi
mk-build-deps -i -r -t "apt-get -y --no-install-recommends -o Debug::pkgProblemResolver=yes" debian/control > ../builddeps.log 2>&1 || { echo "BUILDDEP FAIL"; tail -20 ../builddeps.log; exit 1; }
dpkg-buildpackage -b -uc -us > ../build.log 2>&1 || { echo "BUILD FAIL"; tail -30 ../build.log; exit 1; }
cd ..; ls *.deb
debs=$(ls ./*.deb | grep -v -E -- '-dbgsym_')
if ! apt-get -y --no-install-recommends install $debs > install.log 2>&1; then
  # a package of this module may depend on a module later in the queue (e.g. kde-config-screenlocker -> systemsettings 6.8):
  # install the rest now, the deferred ones are listed in /root/build/deferred.txt and installed when their dependency is there
  # only the packages whose dependency cannot be installed on its own (the other lines are follow-up errors of apt)
  bad=$(sed -n 's/^ \([a-z0-9.+-]*\) : \(Pre\)\?Depends: \([a-z0-9.+-]*\).*/\1 \3/p' install.log | while read pk dep; do
    apt-get -s -q install "$dep" >/dev/null 2>&1 || echo "$pk"; done | sort -u)
  [ -n "$bad" ] || { echo "INSTALL FAIL"; tail -20 install.log; exit 1; }
  rest=$(for d in $debs; do n=$(dpkg-deb -f $d Package); echo "$bad" | grep -qx "$n" && echo "$(pwd)/${d#./}" >> /root/build/deferred.txt || echo $d; done)
  echo "deferred: $bad"
  apt-get -y --no-install-recommends install $rest > install.log 2>&1 || { echo "INSTALL FAIL"; tail -20 install.log; exit 1; }
fi
echo "DONE $M"
