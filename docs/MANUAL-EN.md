# Debian + Plasma Mobile 6.8.3 on a mainline kernel for the Samsung Galaxy M52 5G (m52xq) — full manual

Release "unofficial v1", 2026-11-23. Russian version: [MANUAL-RU.md](MANUAL-RU.md).

## 1. What this is

Debian forky (testing) arm64 with systemd and **KDE Plasma Mobile 6.8.3** (KDE Frameworks 6.30, Qt 6.11) on a mainline Linux 7.1.13
kernel for the Samsung Galaxy M52 5G (SM-M526B / SM-M526BR, Snapdragon 778G / SM7325 "yupik"). No Halium, no libhybris, no Android
kernel or Android services. Debian forky has Plasma 6.7; all Plasma 6.8.3 modules are built for this port. The kernel, device tree
and `m52xq-*` services are shared with the Debian Phosh, postmarketOS and Ubuntu Lomiri ports. The boot image uses the postmarketOS
initramfs, which mounts the Debian root from the `system` partition. Personal, unofficial project; tested on one SM-M526BR.

## 2. What works

See the table in the [README](../README.md#what-works) and the [known issues](../README.md#known-issues).

## 3. Requirements

- Unlocked bootloader (OEM unlock), TWRP for m52xq:
  <https://github.com/saadelasfur/Action-Recovery-Builder/releases/tag/20261004173308>.
- Backups of EFS, persist, modem, boot, vendor_boot and vbmeta (TWRP Backup) and the stock firmware for Odin.
- A Samsung-based ROM installed before (stock, UN1CA or LineageOS): the installer copies the device firmware from its `vendor`,
  `apnhlos`, `modem`, `persist` and `efs` partitions. UN1CA_3.1.0 gives the largest `system` partition.

## 4. Installation

### 4.1. Flashable zip (TWRP)

Video guide: <https://www.youtube.com/watch?v=f1Jyf0NcX0M>

1. Copy [debian-plasma-mobile-m52xq-mainline-v1.zip](https://drive.google.com/file/d/1RBB5iu6X1_HuRpaFq_SBQ2Z3bwgMjOoi/view?usp=sharing)
   (md5 `ebb4aae33a465c16a5c1c74845d4e644`) to the microSD card (or `adb push` it to `/data` after Format Data in TWRP).
2. In TWRP:

```
Wipe - Format Data - yes - enter - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - Select Storage - Micro SD card - debian-plasma-mobile-m52xq-mainline-v1.zip - Swipe to confirm Flash - Reboot System
```

3. Wait for `Updater process ended with RC=0` (about two minutes). The first boot takes longer, then the first-start wizard appears.

What the installer does: grows `system` to 8 000 000 000 bytes in the LP metadata, checks that the root image fits, writes the image
from its two chunks, writes boot, vendor_boot and dtbo, copies the device firmware from the phone's own partitions (read-only), adds
the IPA firmware to the boot ramdisk, sets up the sensor registry for the ADSP, enables the services and sets up `/home` on the
userdata partition. The `m52xq-*` overlay is already inside the image.

The phone gets warm during the install. If the display already shows vertical coloured lines, do not install.

### 4.2. Password and access

- Default password (screen unlock, `user`, `root`): `1111`. Change it with `passwd` in QMLKonsole.
- SSH over USB (about 30 s after boot): `ssh root@172.16.42.1`, password `1111`.
- Screenshot: Volume Up + Volume Down, saved to `~/Pictures/Screenshots`.
- "Reboot menu" app: reboot, reboot into recovery (TWRP), power off; "SIM cards manager": both SIMs / one SIM, data SIM.
- Mobile data: the tile switches the connection "Mobile data" (APN `internet`).

### 4.3. Updates

27 packages are on `apt-mark hold` (`apt-mark showhold`): do not unhold them, or calls, dual SIM, the camera and sleep break. The Plasma
6.8.3 packages (`…-0m52xq1/2/3`) are newer than the ones of Debian forky and stay until Debian gets a newer Plasma; check every upgrade
with `apt-get -s` first. `apt update` reports an error for the local build repository: remove `/etc/apt/sources.list.d/m52xq-plasma.list`.

## 5. Going back to Android

Video guide: <https://www.youtube.com/watch?v=0lgLbtdl4rA>

Enter TWRP ("Reboot menu" - "Reboot into recovery", or power + volume keys). Copy the ROM zip to the microSD card first.

```
Wipe - Format Data - yes - enter - Back - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - lineage-23.2-2026-nightly-m52xq-signed.zip - Back - Back - Wipe - Format Data - yes - enter - Reboot System
```

The LineageOS and UN1CA zips rewrite boot, vendor_boot and dtbo themselves. Stock firmware: Odin or Heimdall (BL, AP, CP, CSC).

## 6. Kernel

Mainline Linux 7.1.13, source <https://github.com/korryasdlerto-lgtm/sc7280-mainline-linux-m52xq>, config and the patches of this release
in [`../kernel/`](../kernel/README.md). The images are in the zip (`firmware/`). The DTB comes from [`../device-tree/`](../device-tree).

## 7. Building from scratch

1. Build chroot: `debootstrap --arch=arm64 forky rootfs-plasma` with qemu-user-static, and a native amd64 chroot with the cross compiler
   ([`../build/crossdirect/`](../build/crossdirect/README.md): C++ 5–50 times faster). Commands: [ИНСТРУКЦИЯ.md](ИНСТРУКЦИЯ.md), 2026-11-13.
2. Plasma 6.8.3: the tarballs of [`../build/plasma-6.8.3-tarballs.txt`](../build/plasma-6.8.3-tarballs.txt) + the Debian 6.7.4 packaging, one module
   at a time with `build/scripts/build-mod.sh`, order in `queue.sh`, packaging fixes in `build/fixups/<module>.sh`. Our patches
   ([`../build/patches/`](../build/patches)) are added by the fixups; `M52XQ_REV=2 m52xq-build-mod <module>` gives `-0m52xq2`.
   Look for `PATCH FAIL` in the log: the script drops patches that do not apply.
3. Hardware packages: the folders of [`../build/`](../build) (ModemManager, NetworkManager, libcamera → PipeWire → Snapshot and m52xq-rawphoto,
   libssc), `apt-get source` + patches + `dpkg-buildpackage -B`, then `apt-mark hold`.
4. Phone root: a copy of the Debian Phosh root without Phosh + the Plasma packages from a local repository (steps P1–P8 of
   [ИНСТРУКЦИЯ.md](ИНСТРУКЦИЯ.md)), greetd autologin into Plasma Mobile, then [`../rootfs-overlay/`](../rootfs-overlay).
5. Telegram: Debian `telegram-desktop` 5.7.2+ds-6 patched with [`../build/telegram/`](../build/telegram).
6. Release image: a TWRP dump of the phone's `system` and the shell settings, cleaned by
   [`../image/build-release.sh`](../image/build-release.sh) ([notes](../image/README.md)); two chunks, `zip -9` from inside the folder.
7. Zip folder layout: `META-INF/` ([`../installer/`](../installer)), `firmware/` (boot, vendor_boot, dtbo-frag), an empty
   `mainline-extras/rootfs-files/` (the overlay is in the image), `data/rootfs-chunks/`.

## 8. Repository layout

See the [README](../README.md#repository-layout).

## 9. Rebuilt programs (`build/`)

See the [README](../README.md#rebuilt-programs-build).

## 10. Services and scripts (overlay)

| Name | What it does |
|---|---|
| `m52xq-adsp-start`, `m52xq-audio-reprobe`, `m52xq-audio-rescue` | start the ADSP once the firmware is on the root; bring the sound card up after the ADSP start race |
| `m52xq-modem-setup`, `m52xq-sim-mode*`, `m52xq-dds`, `m52xq-nas-mode`, `m52xq-flight-mode` | modem session and GNSS setup, SIM mode, data SIM, network modes, cellular flight mode |
| `m52xq-voicecall`, `m52xq-callaudiod`, `m52xq-voice-mixers.sh`, `m52xq-usb-call-bridge` | modem voice path for a call, CallAudio D-Bus API, USB headset bridge |
| `m52xq-tfa-guard` | re-opens the loudspeaker if the TFA9878 amplifier setup fails |
| `m52xq-tg-stream`, `m52xq-voip-audio`, `m52xq-audio-route`, `m52xq-speakerphone` | Telegram calls: earpiece / loudspeaker / headsets, the right microphone |
| `m52xq-call-screen-wake`, `m52xq-notify-screen-wake`, `m52xq-notify-sound`, `m52xq-notify-heal` | a call wakes the screen and raises its window, message notifications and sounds |
| `m52xq-incall-proximity`, `m52xq-sensor-kick`, `m52xq-sensor-reclaim` | screen off at the ear; sensors after the ADSP start and after a resume |
| `m52xq-wifi-soft`, `m52xq-wifi-hw`, `m52xq-wpss-restart`, `m52xq-wl-reset`, `m52xq-wpss-guard` | Wi-Fi tile: real power off / on, cold restart of WPSS (Bluetooth re-init + WL_EN pulse), crash-loop guard |
| system-sleep hooks (`m52xq-*.sh`), `m52xq-wifi-dark`, `m52xq-wow-params` | dark resume, GPS pause, modem 2G in sleep, keep Wi-Fi, Wi-Fi lost, UFS power level, camera, wake-on-LAN flags |
| `m52xq-suspend-guard`, `m52xq-app-reaper`, `m52xq-sleep-report` | retry a failed suspend, log-only app reaper, sleep report |
| `m52xq-gps*`, `m52xq-hotspot*`, `m52xq-nfc` | Location, Hotspot and NFC tiles and their permissions |
| `m52xq-virtualcam`, `m52xq-camera-lock-close`, `m52xq-camera-active` | virtual webcams, camera closed on lock, camera indicator |
| `m52xq-home-on-userdata`, `m52xq-ssh-hostkeys`, `m52xq-bt-firmware`, `m52xq-bt-addr.py` | `/home` on userdata, SSH keys on the first boot, Bluetooth firmware and address |
| `m52xq-vol-screenshot`, `m52xq-reboot-menu`, `m52xq-sim-manager`, `m52xq-backlight-min` | screenshot keys, reboot menu, SIM app, minimal brightness at boot |

## 11. Pitfalls (short)

- `/etc/fstab` must not be empty: the pmOS initramfs then waits for a `pmOS_boot` partition and ends in its debug shell.
- `m52xq-wpss-restart` without the wait for the second Bluetooth setup and the WL_EN pulse: the first Wi-Fi "on" ends in a WPSS crash loop
  (`ccpm_mhi.c:397:mhi_issue_request Failed`), only a reboot helps.
- KWin's Wayland socket is `wayland-1` here; scripts with `wayland-0` silently do nothing.
- plasmashell must start after PowerDevil is on the bus (brightness slider), but an `After=`/`Wants=` creates an ordering cycle: wait in `ExecStartPre`.
- The Plasma home screen layout is tied to the activity id: without `kactivitymanagerdrc` a new install starts empty.
- Snapshot under KWin has no Mutter DisplayConfig: rotation comes from iio-sensor-proxy; rebuild the binary for real (`-nc` may skip it).
- Telegram streams carry no `application.*` properties: identify them by their PulseAudio client.
- The loudspeaker (TFA9878) stays silent in S24_LE: PipeWire opens the card in S16LE. `MODVERSIONS` is off: modules only with the same Image.

## 12. Credits

Debian and Mobian, KDE Plasma Mobile and the KDE developers, GNOME Snapshot, libcamera, PipeWire, ModemManager, NetworkManager, Telegram
Desktop, postmarketOS, the mainline Linux developers for Qualcomm SC7280 / QCM6490, LineageOS (reference sources), the TWRP maintainers
for m52xq.
