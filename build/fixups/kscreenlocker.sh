# kscreenlocker 6.8: no usr/share/ksmserver/ (fallback lock screen theme) any more; KConfigXT file of the screen locker settings
sed -i '\|usr/share/ksmserver/|d' debian/kde-config-screenlocker.install
echo 'usr/share/config.kcfg/' >> debian/kde-config-screenlocker.install
# 6.8: new helper kscreenlocker_worker and the QML module org.kde.kscreenlocker (greeter types)
echo 'usr/lib/${DEB_HOST_MULTIARCH}/libexec/kscreenlocker_worker' >> debian/libkscreenlocker6.install
echo 'usr/lib/${DEB_HOST_MULTIARCH}/qt6/qml/org/kde/kscreenlocker/' >> debian/libkscreenlocker6.install
