# Release image

[`build-release.sh`](build-release.sh) makes the clean root image from a TWRP dump of the phone's `system` partition
(`adb exec-out 'dd if=/dev/block/mapper/system bs=4M' > system-raw.img`, mounted read-only on `mnt-old`) and the shell settings
(`home-config.tar`, `.config` of the user). Every command with its output: [`../docs/ИНСТРУКЦИЯ.md`](../docs/ИНСТРУКЦИЯ.md), 2026-11-23.

- ext4 5400 MiB, label `pmOS_root`, about 256 MiB free for the firmware the installer copies from the phone;
  md5 of the v1 image `183cf29e107016aef468fca0bfe11267`; two equal chunks `data/rootfs-chunks/samsung-m52xq.img.part-0/1`.
- Removed: network connections, Bluetooth and NetworkManager state, SSH host keys, machine-id, SIM mode, logs, `/root`, the user's home,
  proprietary firmware and sensor data. The first-start wizard is reset. The staged overlay is installed file by file (root-owned).
- Checks: no personal values in the files nor in the raw image (free space zero-filled first), `e2fsck -fn` clean.
- Packages of the image: [`../docs/packages-debian.txt`](../docs/packages-debian.txt).
