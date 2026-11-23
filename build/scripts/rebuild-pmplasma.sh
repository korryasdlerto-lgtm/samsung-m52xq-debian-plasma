#!/bin/sh
# m52xq: rebuild the modules that carry the pm-Plasma patches as 6.8.3-0m52xq2, log in work/rebuild-pmplasma.log
B="${B:-$HOME/m52-plasma}"; cd "$B"
for m in plasma-keyboard plasma-nm spacebar plasma-dialer plasma-mobile; do
	echo "$(date +%T) START $m" >> work/rebuild-pmplasma.log
	if sudo chroot rootfs-plasma env M52XQ_REV=2 /usr/local/bin/m52xq-build-mod $m > work/build-$m-r2.out 2>&1; then
		echo "$(date +%T) DONE $m $(grep -c 'PATCH FAIL' work/build-$m-r2.out) dropped patches" >> work/rebuild-pmplasma.log
	else
		echo "$(date +%T) FAIL $m (work/build-$m-r2.out)" >> work/rebuild-pmplasma.log
	fi
done
echo "$(date +%T) ALL DONE" >> work/rebuild-pmplasma.log
