#!/bin/sh
# M52XQ: build the Plasma 6.8.3 modules in dependency order, stop at the first failure
B="${B:-$HOME/m52-plasma}"; cd "$B"
Q="kwayland layer-shell-qt plasma-activities knighttime kpipewire libkscreen libksysguard ocean-sound-theme kglobalacceld libplasma plasma-activities-stats plasma5support breeze aurorae kscreenlocker kwin kactivitymanagerd milou plasma-union qqc2-breeze-style plasma-integration plasma-workspace plasma-nano powerdevil plasma-pa plasma-nm bluedevil kscreen kde-cli-tools polkit-kde-agent-1 xdg-desktop-portal-kde systemsettings kinfocenter ksystemstats kdeplasma-addons plasma-mobile plasma-keyboard plasma-dialer spacebar kwrited"
for m in $Q; do
  if grep -q " DONE $m$" work/queue.log; then echo "$(date +%T) SKIP $m (done)" >> work/queue.log; continue; fi
  echo "$(date +%T) START $m" >> work/queue.log
  if sudo chroot rootfs-plasma /usr/local/bin/m52xq-build-mod $m > work/build-$m.out 2>&1; then
    echo "$(date +%T) DONE $m" >> work/queue.log
  else
    echo "$(date +%T) FAIL $m (work/build-$m.out)" >> work/queue.log; exit 1
  fi
done
echo "$(date +%T) ALL DONE" >> work/queue.log
