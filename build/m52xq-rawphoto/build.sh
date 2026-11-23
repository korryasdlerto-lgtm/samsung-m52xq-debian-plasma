#!/bin/sh
# m52xq-rawphoto for Debian: the same sources as the postmarketOS Phosh port (raw 64 MP / 32 MP capture through libcamera,
# development on the GPU). Run in the arm64 Debian build chroot with libcamera 0.8.0 (../libcamera) installed.
# Result: m52xq-rawphoto_1-3+deb1_arm64.deb (/usr/bin/m52xq-rawphoto, NEEDED libcamera.so.0.8).
set -e
cd "$(dirname "$0")"
gcc -O2 -Wall -c rawphoto.c -o rawphoto.o $(pkg-config --cflags epoxy)
gcc -O2 -Wall -c photo_gpu.c -o photo_gpu.o $(pkg-config --cflags epoxy libjpeg)
g++ -O2 -Wall -std=c++20 -c m52xq-rawphoto.cpp -o m52xq-rawphoto.o $(pkg-config --cflags libcamera)
g++ -o m52xq-rawphoto m52xq-rawphoto.o rawphoto.o photo_gpu.o $(pkg-config --libs libcamera epoxy libjpeg) -lm
strip m52xq-rawphoto
P=$(mktemp -d)
install -Dm755 m52xq-rawphoto "$P/usr/bin/m52xq-rawphoto"
mkdir -p "$P/DEBIAN"
cat > "$P/DEBIAN/control" <<CTRL
Package: m52xq-rawphoto
Version: 1-3+deb1
Architecture: arm64
Maintainer: Asdlerto Korry <korryasdlerto@gmail.com>
Depends: libcamera0.8, libepoxy0, libjpeg62-turbo, libstdc++6, libc6
Section: graphics
Priority: optional
Description: Samsung Galaxy M52 5G: full-resolution raw photo capture and GPU development
 64 MP (main) / 32 MP (front) photos for GNOME Snapshot: raw capture through libcamera, development on the GPU.
 Same source as the postmarketOS Phosh v1 package m52xq-rawphoto 1-r3.
CTRL
dpkg-deb --root-owner-group -b "$P" m52xq-rawphoto_1-3+deb1_arm64.deb
