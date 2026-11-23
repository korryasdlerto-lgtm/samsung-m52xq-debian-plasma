# plasma-workspace 6.8: no X11 session any more (startplasma-x11, plasmax11.desktop, kcminit, krdb) -> drop them from the
# Debian 6.7 .install files; the x-session-manager alternative (startplasma-x11) is gone too -> empty postinst/prerm
sed -i '\|usr/bin/kcminit$|d; \|usr/bin/kcminit_startup$|d; \|usr/bin/startplasma-x11$|d; \|usr/share/xsessions/plasmax11.desktop$|d' debian/plasma-workspace.install
sed -i '\|usr/include/krdb/$|d; \|cmake/Krdb/$|d' debian/plasma-workspace-dev.install
sed -i '\|libkrdb.so$|d' debian/libklookandfeel6.install
printf '#!/bin/sh\nset -e\n#DEBHELPER#\nexit 0\n' > debian/plasma-workspace.postinst
printf '#!/bin/sh\nset -e\n#DEBHELPER#\nexit 0\n' > debian/plasma-workspace.prerm
! grep -q 'startplasma-x11\|kcminit\|krdb\|Krdb' debian/plasma-workspace.install debian/plasma-workspace-dev.install debian/libklookandfeel6.install
# new files of 6.8 (dh_missing): into plasma-workspace
for f in 'usr/lib/${DEB_HOST_MULTIARCH}/kconf_update_bin/plasma6.8-remove-action-menu-shortcut' \
         'usr/lib/${DEB_HOST_MULTIARCH}/libexec/plasma-setup-xwayland' \
         'usr/lib/${DEB_HOST_MULTIARCH}/qt6/qml/org/kde/kworkspace/' \
         'usr/lib/${DEB_HOST_MULTIARCH}/qt6/qml/org/kde/plasma/shell/' \
         'usr/lib/${DEB_HOST_MULTIARCH}/qt6/qml/org/kde/plasma/workspace/loginlockscreen/'; do
  grep -qxF "$f" debian/plasma-workspace.install || echo "$f" >> debian/plasma-workspace.install
done
# drkonqi (crash reporter) exists only as Debian 6.7 (needs plasma-version-base-6.7): not needed on the phone -> no dependency
sed -i '/^ *drkonqi (>= [^)]*),$/d' debian/control
! grep -q 'drkonqi (' debian/control
