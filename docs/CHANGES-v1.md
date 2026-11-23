# Unofficial v1 (first public release)

| | |
|---|---|
| Kernel | 7.1.13, the same build as Debian Phosh / postmarketOS Phosh v1 (`kernel/patches/`) |
| Root | Debian forky arm64, Plasma Mobile 6.8.3 (own build), KDE Frameworks 6.30, Qt 6.11; 1815 packages ([list](packages-debian.txt)), 27 on hold |
| Image | dump of the phone's system partition taken in TWRP, cleaned of personal data, keys and proprietary firmware; ext4 5400 MiB, 2 chunks |
| Zip | `debian-plasma-mobile-m52xq-mainline-v1.zip` (1.69 GB), md5 `ebb4aae33a465c16a5c1c74845d4e644` |

- **Wi-Fi tile** powers Wi-Fi off for real (ath11k unloaded, WPSS stopped) and on again without a firmware crash loop: `m52xq-wpss-restart`
  waits for the second Bluetooth setup and pulses WL_EN (`m52xq-wl-reset`); checked: 2 full cycles + Bluetooth on, 0 crashes.
- **Telegram:** an incoming call wakes the screen and brings the call window to the front, a message does not (`m52xq-call-screen-wake`
  looks at the client of the sound stream); switching the camera off / on in a call no longer crashes (8-byte patch, `build/telegram`).
- **Camera:** GNOME Snapshot m52xq6: rotation from the accelerometer (KWin has no Mutter DisplayConfig), correct orientation after
  switching cameras; libcamera 0.8, PipeWire rebuilt against it.
- Quick-settings tiles NFC, Location, Speakerphone, Sound output, Hotspot; brightness slider fixed (plasmashell starts after
  PowerDevil is on the bus).
- `/home` on the userdata partition; Venus modules, loudspeaker shared-SE fix and USB audio of the Phosh release.
- Wi-Fi without an access point before sleep: ath11k is unloaded for the sleep (`m52xq-wifi-lost.sh`).

Known issues: see the README.
