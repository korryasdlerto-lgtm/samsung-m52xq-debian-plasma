# samsung-m52xq-debian-plasma

**Debian forky (testing) + KDE Plasma Mobile 6.8.3** on a **mainline Linux kernel** for the **Samsung Galaxy M52 5G**
(codename `m52xq`, SM-M526B / SM-M526BR, Qualcomm Snapdragon 778G / SM7325, platform "yupik").

It is not Halium, not libhybris and not the Android kernel. The phone runs a mainline Linux 7.1.13 kernel with device drivers and
fixes, and a real Debian forky arm64 root with systemd. Debian forky has Plasma 6.7, so **Plasma 6.8.3 is built for this port** from
the KDE release tarballs (Qt 6.11 and KDE Frameworks 6.30 come from Debian). The hardware layer (kernel, `m52xq-*` services) is the
same as in the sister ports [samsung-m52xq-debian-phosh](https://github.com/korryasdlerto-lgtm/samsung-m52xq-debian-phosh),
[samsung-m52xq-postmarketos-phosh](https://github.com/korryasdlerto-lgtm/samsung-m52xq-postmarketos-phosh) and
[samsung-m52xq-mainline](https://github.com/korryasdlerto-lgtm/samsung-m52xq-mainline) (postmarketOS Plasma Mobile).
Personal, unofficial project (not a Debian or KDE release), tested on one SM-M526BR.

**Status (release "unofficial v1", 2026-11-23, see [changes](docs/CHANGES-v1.md) / [на русском](docs/CHANGES-v1-RU.md)):
usable, but not yet ready as your only phone.**

## Repositories

| | |
|---|---|
| This repository | installer, rootfs overlay (scripts, services, configs), patches and build scripts of Plasma 6.8.3 and the rebuilt Debian packages, image build script, device tree, kernel config and patches, documentation |
| Kernel source | [sc7280-mainline-linux-m52xq](https://github.com/korryasdlerto-lgtm/sc7280-mainline-linux-m52xq); the patches of this release on top of it are in [`kernel/patches/`](kernel/patches) |
| Kernel binaries | boot.img, vendor_boot.img and dtbo of this release are inside the flashable zip (`firmware/`) |
| XDA thread | [[ROM][UNOFFICIAL][Debian][Plasma Mobile] Mainline Linux 7.1 for Galaxy M52 5G](https://xdaforums.com/t/rom-unofficial-debian-plasma-mobile-mainline-linux-7-1-for-galaxy-m52-5g-sm-m526b-sm-m526br.4809914/) |

## What works

| Feature | Status | Notes |
|---|---|---|
| Boot, UFS storage | works | `system` grown to 8 GB by the installer; `/home` on the userdata partition (about 100 GB) |
| Display, GPU (Adreno 642L) | works | Samsung S6E3HAB AMOLED, brightness, auto-rotation; Mesa freedreno, KWin composited on the GPU |
| Touchscreen, keyboard | works | Synaptics; Plasma Keyboard |
| Wi-Fi, Bluetooth | works | WCN6750 / ath11k; the Wi-Fi tile really powers Wi-Fi off and on (15–40 s to switch on) |
| Calls, SMS, mobile data | works | **dual SIM** (both active), SIM cards manager; "Mobile data" connection, APN `internet` |
| Audio | works | loudspeaker, earpiece, microphones, in-call noise suppression, USB-C and Bluetooth headsets in calls |
| GPS | works | ModemManager GNSS, GeoClue, Location tile |
| Sensors | works | light, proximity (screen off at the ear), accelerometer |
| Battery, charging | works | SM5714 fuel gauge and charger, Samsung AFC 9 V |
| Suspend | works | s2idle; wakes for calls and SMS; the screen stays dark on network wake-ups; about 0.75 %/h with the radios off |
| Cameras | works | GNOME Snapshot with all four cameras, tap to focus, zoom, 64 MP / 32 MP photos, Venus video encoding; software image processing |
| Telegram | works | Telegram Desktop: voice and video calls, a call wakes the screen, a message does not; camera through virtual webcams |
| Quick settings | works | own tiles: NFC, Location, Speakerphone, Sound output, Hotspot (partly tested) |
| NFC | partial | on/off only |
| Fingerprint, VoLTE | no | calls use 2G/3G |

### Known issues

- **Empty home screen** after the install: add icons from the app drawer.
- **`apt update`** reports an error for the local build repository: `sudo rm /etc/apt/sources.list.d/m52xq-plasma.list`.
- Turning Wi-Fi on takes up to 40 s and restarts Bluetooth (the WCN6750 chip is shared and has to be reset).
- Sensors may stop after many hours of sleep until a reboot (FastRPC).
- If the router disappears while the phone sleeps, the Wi-Fi firmware may crash on wake-up; reboot.
- Location may not be switched on again by itself after a reboot.
- Video playback in the browser is decoded in software.

## Install

Video guide: <https://www.youtube.com/watch?v=f1Jyf0NcX0M> (in the video I switch from one Linux system to another; UN1CA is only
needed when coming from Android).

- Zip (1.7 GB): [debian-plasma-mobile-m52xq-mainline-v1.zip](https://drive.google.com/file/d/1RBB5iu6X1_HuRpaFq_SBQ2Z3bwgMjOoi/view?usp=sharing),
  md5 `ebb4aae33a465c16a5c1c74845d4e644`
- TWRP for m52xq: <https://github.com/saadelasfur/Action-Recovery-Builder/releases/tag/20261004173308>
- Back up EFS, persist, modem, boot, vendor_boot and vbmeta first. If you are not comfortable restoring a Samsung phone with Odin,
  do not install this. The phone gets warm during the install: if the display already shows vertical coloured lines, do not install.

```
Wipe - Format Data - yes - enter - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - Select Storage - Micro SD card - UN1CA_3.1.0-a5bf09f2_20260604_m52xq-sign.zip - Swipe to confirm Flash - Back - Back - Wipe - Format Data - yes - enter - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - debian-plasma-mobile-m52xq-mainline-v1.zip - Swipe to confirm Flash - Reboot System
```

Default password (screen unlock, `user` and `root`): `1111`. SSH over USB: `ssh root@172.16.42.1`.

The zip contains no proprietary firmware except the Wi-Fi firmware: the installer copies the ADSP, IPA, Venus, GPU zap shader,
Bluetooth, modem and sensor files from the phone's own `apnhlos`, `vendor`, `modem`, `persist` and `EFS` partitions (read-only).

### Back to Android

Video guide: <https://www.youtube.com/watch?v=0lgLbtdl4rA>

Enter TWRP (app "Reboot menu" - "Reboot into recovery", or the power and volume button combination). Copy the firmware zip to
the microSD card first. The LineageOS and UN1CA zips rewrite boot, vendor_boot and dtbo themselves.

```
Wipe - Format Data - yes - enter - Back - Back - Back - Advanced Wipe - Data - Repair or Change File System - Change File System - EXT4 - Swipe to Change - Back - Back - Back - Back - Back - Install - lineage-23.2-2026-nightly-m52xq-signed.zip - Back - Back - Wipe - Format Data - yes - enter - Reboot System
```

Latest LineageOS build: <https://download.lineageos.org/devices/m52xq/builds>. Stock firmware: Odin or Heimdall.

## Repository layout

| Path | Content |
|---|---|
| `installer/` | `META-INF/.../update-binary` of the flashable zip |
| `rootfs-overlay/` | our files over the Debian root: `m52xq-*` scripts, services, system-sleep hooks, quick-settings tiles, configs. Binaries are listed in `EXCLUDED-FILES.txt` (path, size, md5) |
| `build/scripts`, `build/fixups` | Plasma 6.8.3 on the Debian 6.7.4 packaging: `build-mod.sh` (one module in an arm64 chroot), `queue.sh`, per-module packaging fixes; `build/crossdirect` (native cross compiler), `build/plasma-6.8.3-tarballs.txt` |
| `build/patches` | our patches to plasma-mobile, plasma-nm, plasma-dialer, plasma-keyboard, spacebar (dual SIM, data icon, notification reply, key tones, ...) |
| `build/<package>` | rebuilt hardware packages: ModemManager, NetworkManager, libcamera, PipeWire, GNOME Snapshot, m52xq-rawphoto, libssc, the Telegram patch |
| `kernel/`, `device-tree/` | kernel config and patches on top of [sc7280-mainline-linux-m52xq](https://github.com/korryasdlerto-lgtm/sc7280-mainline-linux-m52xq), DTS of the release |
| `image/` | `build-release.sh`: root image from a TWRP dump of the phone, cleaned |
| `docs/` | changes of v1 (EN/RU), packages of the image, manuals (EN/RU), step-by-step build commands (`ИНСТРУКЦИЯ.md`) and change log by build (`ПРАВКИ.md`, Russian, personal data removed) |

### Rebuilt programs (`build/`)

| Folder | What and why |
|---|---|
| `scripts`, `fixups`, `crossdirect`, `plasma-6.8.3-tarballs.txt` | all Plasma 6.8.3 modules on the Debian 6.7.4 packaging (`…-0m52xqN`) |
| `patches/plasma-mobile` | camera / location indicators, default action of a notification, dual-SIM signal, data SIM mark, Folio favourites, mobile data icon, notification reply |
| `patches/plasma-nm` | SIM numbered by the card slot, the Wi-Fi switch of the settings works like the tile |
| `patches/plasma-dialer`, `patches/spacebar` | key tones, default open action, dual SIM, speaker sync; multi-modem SMS, delivery reports, persistent notification |
| `patches/plasma-keyboard` | key sound option name |
| `modemmanager`, `network-manager` | dual SIM (DSDS) and suspend fixes; option to ignore the logind sleep signal |
| `libcamera`, `pipewire`, `snapshot`, `m52xq-rawphoto` | camera stack: soft-ISP, four cameras, 64 MP photos, Venus video; Snapshot 0003 / 0004: rotation under KWin |
| `libssc` | sensors: proximity fixes |
| `telegram` | 8-byte patch of telegram-desktop: camera off / on in a call no longer crashes |

The `.deb` packages themselves are not in the repository.

## Building

See the manual, section 7: [English](docs/MANUAL-EN.md#7-building-from-scratch) / [Русский](docs/MANUAL-RU.md).

## Manuals

| Language | Markdown |
|---|---|
| English | [docs/MANUAL-EN.md](docs/MANUAL-EN.md) |
| Русский | [docs/MANUAL-RU.md](docs/MANUAL-RU.md) |

Step-by-step commands with output (Russian): [docs/ИНСТРУКЦИЯ.md](docs/ИНСТРУКЦИЯ.md); change log by build: [docs/ПРАВКИ.md](docs/ПРАВКИ.md).

## Bug reports

Please write in the [XDA thread](https://xdaforums.com/t/rom-unofficial-debian-plasma-mobile-mainline-linux-7-1-for-galaxy-m52-5g-sm-m526b-sm-m526br.4809914/): your model (SM-M526B / SM-M526BR), what you did and what happened. Logs help a lot: `journalctl -b` and `dmesg`
over SSH or in QMLKonsole.

## Credits

Debian and Mobian, KDE Plasma Mobile and the KDE developers, GNOME Snapshot, libcamera, PipeWire, ModemManager, NetworkManager,
Telegram Desktop, postmarketOS, the mainline Linux developers for Qualcomm SC7280 / QCM6490 (Fairphone 5 and others), LineageOS
(reference sources), the TWRP maintainers for m52xq.

## License

Kernel code: GPL-2.0 (see the kernel repository). Patches follow the license of the patched project. Scripts and documentation in
this repository: GPL-2.0.

Author: Asdlerto Korry
