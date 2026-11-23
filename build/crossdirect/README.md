# crossdirect (fast compiling in the arm64 chroot)

The arm64 rootfs is built on an x86_64 PC; every program in it runs through qemu-user, which makes C++ 5–50 times slower.
As in pmbootstrap, the compiler is replaced by the native x86_64 cross compiler of the same version:

1. `debootstrap --arch amd64 --variant=minbase forky native-amd64`; in it `apt-get install g++-aarch64-linux-gnu gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu` (GCC 16.2, as in the arm64 rootfs);
2. `mount --bind native-amd64 rootfs-plasma/native` (read-only);
3. in the arm64 rootfs: `lib64/ld-linux-x86-64.so.2 -> /native/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2`,
   directory `usr/aarch64-linux-gnu/` with only `lib -> /native/usr/aarch64-linux-gnu/lib` (a link of the whole directory breaks the emulated gcc: it then finds the x86 `as`);
4. wrappers `usr/lib/m52xq-cross/aarch64-linux-gnu-{gcc,g++,cpp}[-16]` (this directory, one example), first in PATH of `build-mod.sh`.

Test: Qt6 hello world 49 s emulated → 1 s; identical machine code (only the GCC version string differs).
