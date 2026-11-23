# kwin 6.8: kwin5_update_default_rules is gone (newer kconf_update helpers instead), usr/share/kwin-wayland/ is merged into usr/share/kwin/
sed -i '/kwin5_update_default_rules/d' debian/kwin-common.install
sed -i '\|usr/share/kwin-wayland/|d' debian/kwin-data.install
grep -qx 'usr/share/kwin/' debian/kwin-data.install || echo 'usr/share/kwin/' >> debian/kwin-data.install
