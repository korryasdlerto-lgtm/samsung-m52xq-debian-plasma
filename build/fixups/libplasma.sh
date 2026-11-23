# libplasma 6.8: soname 7 -> 8 (libPlasma.so.8, libPlasmaQuick.so.8): binary packages libplasma7/libplasmaquick7 -> libplasma8/libplasmaquick8;
# the 6.7 symbols files are dropped (dpkg-gensymbols writes new ones)
sed -i 's/\blibplasma7\b/libplasma8/g; s/\blibplasmaquick7\b/libplasmaquick8/g' debian/control
for p in libplasma libplasmaquick; do
  sed 's/\.so\.7$/.so.8/' debian/${p}7.install > debian/${p}8.install
  rm -f debian/${p}7.install debian/${p}7.symbols
  [ -f debian/${p}7.lintian-overrides ] && mv debian/${p}7.lintian-overrides debian/${p}8.lintian-overrides || true
done
# 6.8 also installs the Qt metatypes of the libraries
echo 'usr/lib/${DEB_HOST_MULTIARCH}/qt6/metatypes/' >> debian/libplasma-dev.install
