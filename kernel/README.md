# Kernel of the release

Mainline Linux 7.1.13 for the Samsung Galaxy M52 5G (m52xq), the same build as in the postmarketOS Phosh port
([samsung-m52xq-postmarketos-phosh](https://github.com/korryasdlerto-lgtm/samsung-m52xq-postmarketos-phosh)).
Source: <https://github.com/korryasdlerto-lgtm/sc7280-mainline-linux-m52xq>. Config: [`config-7.1.13`](config-7.1.13).

The binaries are inside the flashable zip, folder `firmware/`:

| File | What |
|---|---|
| `boot_*.img` | boot.img: the kernel with the appended DTB tail and the pmOS initramfs, no AVB footer; the installer adds the IPA firmware of the phone being flashed (from `apnhlos`) to the ramdisk |
| `vendor_boot_*.img` | vendor_boot: DTB of [`../device-tree/sm7325-samsung-m52xq-local.dts`](../device-tree) (RTC enabled), cmdline with `snd_usb_audio.index=-2` (the built-in sound card stays card 0 when a USB headset is plugged in at boot) |
| `dtbo-frag-*.img` | dtbo with one harmless fragment (the bootloader needs a dtbo for this DTB) |

The kernel modules are in the root image (`/usr/lib/modules/7.1.13`); the Venus modules of this build are put over them by
the installer (`mainline-extras/rootfs-files`, listed in `../rootfs-overlay/EXCLUDED-FILES.txt`).
`MODVERSIONS` is off: use the modules only with the same Image.

## Patches on top of the kernel repository (`patches/`)

| Patch | Why |
|---|---|
| `m52xq-q6voice-in-place-device-switch.diff` | calls: switch speaker / earpiece without new voice sessions (the audio DSP crashed when a session was recreated in a call) |
| `m52xq-panel-sleep-while-brightness-0.diff` | the panel stays asleep on network wake-ups while the brightness is 0 (no flash) |
| `m52xq-ath11k-radio-off-power-save.diff` | Wi-Fi switched off really lets the WCN6750 firmware sleep |
| `m52xq-gpi-shared-se-read-fix.diff` | GPI DMA / I2C GENI: a read on a serial engine shared with another driver completed too early; the loudspeaker amplifier (TFA9878) sometimes stayed silent in calls |
| `m52xq-venus-hfi6xx-qp-bitrate.diff` | Venus encoder on HFI 6xx (Iris2): frame QP and bitrate are sent in the form the firmware understands |

## Building

`make ARCH=arm64 LLVM=1 Image modules` with clang/LLD 22 (pmbootstrap Alpine native chroot); Venus as out-of-tree modules
`make M=drivers/media/platform/qcom/venus modules` (`KBUILD_MODPOST_WARN=1`). The boot image is the previous boot.img with
the new `Image` and the appended DTB tail.
