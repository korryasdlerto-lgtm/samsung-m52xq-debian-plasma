# kglobalacceld 6.8: only the library libKGlobalAccelD is installed (the daemon is part of kwin now); no X11 platform plugin
sed -i '/autostart\/kglobalacceld.desktop/d; /libexec\/kglobalacceld/d; /plasma-kglobalaccel.service/d' debian/kglobalacceld.install
sed -i '/KGlobalAccelDXcb.so/d' debian/libkglobalacceld0.install
