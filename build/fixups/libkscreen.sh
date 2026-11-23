# libkscreen 6.8: the KWayland backend is built into libKF6Screen; no backend launcher, plugins or services any more
sed -i '/kscreen_backend_launcher/d; /plugins\/kf6\/kscreen/d; /plasma-kscreen.service/d; /org.kde.kscreen.service/d' debian/libkscreen-bin.install
