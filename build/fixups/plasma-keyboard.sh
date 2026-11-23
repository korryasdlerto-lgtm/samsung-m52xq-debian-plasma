# pm-Plasma patches (m52xq, ported to 6.8.3 on 2026-11-14): copied from /root/pmplasma-patches/plasma-keyboard, applied by quilt after the Debian ones
mkdir -p debian/patches; touch debian/patches/series
cp /root/pmplasma-patches/plasma-keyboard/plasma-keyboard-0001-fix-sound-option-name.patch debian/patches/m52xq-plasma-keyboard-0001-fix-sound-option-name.patch; grep -qx 'm52xq-plasma-keyboard-0001-fix-sound-option-name.patch' debian/patches/series || echo 'm52xq-plasma-keyboard-0001-fix-sound-option-name.patch' >> debian/patches/series
