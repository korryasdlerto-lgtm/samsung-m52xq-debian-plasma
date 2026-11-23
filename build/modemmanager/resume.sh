#!/bin/sh
export DEBIAN_FRONTEND=noninteractive LC_ALL=C DEBFULLNAME="Asdlerto Korry" DEBEMAIL="korryasdlerto@gmail.com" DEB_BUILD_OPTIONS="nocheck nodoc parallel=16"
cd /root/src/modemmanager-1.24.2 || exit 1
# the documentation (gtk-doc, xsltproc under qemu) took more than 15 minutes and is not needed: turn it off in the existing build directory
( cd obj-aarch64-linux-gnu && meson configure -Dgtk_doc=false ) || exit 2
dpkg-buildpackage -B -us -uc -nc
