#!/bin/bash
# Debian Plasma Mobile public release v1: image from a TWRP dump of the phone's system partition (system-raw.img, mounted read-only on mnt-old) and
# the user settings (home-config.tar of /data/home/user/.config). Run in the folder with both files.
set -e
OLD=mnt-old; NEW=mnt-new; P=..; SIZE=$1   # MiB
I=debian-plasma-m52xq-v5-min.img
mountpoint -q $OLD
rm -f $I; truncate -s ${SIZE}M $I; mkfs.ext4 -q -F -L pmOS_root -O ^metadata_csum_seed $I
mkdir -p $NEW; sudo mount -o loop $I $NEW
sudo rsync -aHAX --numeric-ids --exclude=/home/user/ --exclude=/var/log/journal/ --exclude='/var/cache/apt/archives/*.deb' --exclude='/var/lib/apt/lists/*' \
  --exclude='/tmp/*' --exclude='/var/tmp/*' --exclude='/var/lib/systemd/coredump/*' --exclude=/lost+found --exclude='/var/log/*.gz' \
  --exclude='/root/*' --exclude='/root/.cache' --exclude='/root/.config' --exclude='/root/.ssh' --exclude='/root/.bash_history' \
  $OLD/ $NEW/
sudo install -m644 $OLD/root/.bashrc $OLD/root/.profile $NEW/root/
for d in proc sys dev run tmp var/tmp var/log/journal var/lib/apt/lists/partial var/cache/apt/archives/partial home/user; do sudo mkdir -p $NEW/$d; done
sudo chmod 1777 $NEW/tmp $NEW/var/tmp
# home: the clean one + shell/screen/power settings, the first-start wizard not yet run
sudo cp -a $P/rootfs-phone/home/user/. $NEW/home/user/
sudo tar -xpf home-config.tar -C $NEW/home/user .config/kscreenlockerrc .config/powerdevilrc .config/powermanagementprofilesrc .config/kwinrc .config/kdeglobals \
  .config/kglobalshortcutsrc .config/kwinoutputconfig.json .config/plasmamobilerc .config/plasmashellrc .config/plasma-mobile \
  .config/plasma-org.kde.plasma.mobileshell-appletsrc .config/kdedefaults
sudo sed -i '/^\[InitialStart\]$/,/^\[/{/^\[InitialStart\]$/d;/^wizardRun=/d}' $NEW/home/user/.config/plasmamobilerc
! sudo grep -q wizardRun $NEW/home/user/.config/plasmamobilerc || { echo 'ERROR: wizardRun'; exit 1; }
sudo chown -R 10000:10000 $NEW/home/user
# state and identity of this phone (sudo sh -c: the directories are root-only, the globs must expand as root)
sudo sh -c "cd $NEW && rm -rf etc/NetworkManager/system-connections/* var/lib/NetworkManager/* var/lib/bluetooth/* var/lib/geoclue/* var/lib/upower/* \
  var/lib/systemd/rfkill/* var/lib/systemd/random-seed var/lib/m52xq/* var/lib/dbus/machine-id etc/m52xq/bt_addr etc/m52xq/wifi_mac etc/m52xq/sim-mode \
  etc/m52xq/data-sim etc/m52xq/flight etc/ssh/ssh_host_* var/lib/wtmpdb/*; : > etc/machine-id; ln -sf /etc/machine-id var/lib/dbus/machine-id; \
  find var/log -type f \( -name '*.gz' -o -name '*.[0-9]' -o -name '*.old' \) -delete; find var/log -type f -exec truncate -s 0 {} +"
sudo install -m644 $P/repo/rootfs-overlay/etc/systemd/system/m52xq-ssh-hostkeys.service $NEW/etc/systemd/system/
sudo mkdir -p $NEW/etc/systemd/system/multi-user.target.wants
sudo ln -sf ../m52xq-ssh-hostkeys.service $NEW/etc/systemd/system/multi-user.target.wants/m52xq-ssh-hostkeys.service
# proprietary firmware and sensor data (the installer copies them from the phone being flashed)
F=$NEW/usr/lib/firmware; SN=$NEW/usr/share/qcom/sm7325/Samsung/m52xq/sensors
sudo sh -c "rm -f $F/adsp.* $F/adspr.jsn $F/adsps.jsn $F/adspua.jsn $F/modem.* $F/modemr.jsn $F/a660_zap.* $F/yupik_ipa_fws.*; rm -rf $F/modem_pr $F/qcom/vpu-2.0 $F/qca $SN/config $SN/registry; rm -f $SN/sns_reg.conf"
# static device nodes
sudo sh -c "cd $NEW/dev; rm -rf ./*; mknod -m 666 null c 1 3; mknod -m 666 zero c 1 5; mknod -m 666 full c 1 7; mknod -m 666 random c 1 8; mknod -m 666 urandom c 1 9; \
  mknod -m 666 tty c 5 0; mknod -m 600 console c 5 1; mknod -m 666 ptmx c 5 2; mkdir pts shm; ln -sf /proc/self/fd fd; ln -sf /proc/self/fd/0 stdin; ln -sf /proc/self/fd/1 stdout; ln -sf /proc/self/fd/2 stderr"
# the staged layer (mainline-extras/rootfs-files) is inside the image: file by file, root-owned, no directory is replaced
RF=$P/repo/rootfs-overlay
(cd $RF && find . \( -type f -o -type l \) ! -name EXCLUDED-FILES.txt) | while read -r f; do
  m=$(stat -c %a "$RF/$f"); case $f in *.nmconnection) m=600;; esac
  sudo mkdir -p "$NEW/$(dirname "$f")"
  if [ -L "$RF/$f" ]; then sudo cp -P --no-preserve=ownership "$RF/$f" "$NEW/$f"; else sudo install -o root -g root -m $m "$RF/$f" "$NEW/$f"; fi
done
case $(sudo md5sum $NEW/usr/bin/telegram-desktop) in d1ec1967d009f3c29fdb97021e9e9d18*) ;; *) echo 'ERROR: telegram-desktop'; exit 1;; esac
df -m $NEW | tail -1
