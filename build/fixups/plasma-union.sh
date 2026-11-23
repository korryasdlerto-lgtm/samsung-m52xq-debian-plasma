# plasma-union 6.8: plasma-workspace 6.8 needs find_package(Union) -> keep libUnion.so, the headers and cmake/Union in kde-style-union
# (the Debian 6.7 rules remove them in execute_after_dh_auto_install)
sed -i '\|rm -f debian/kde-style-union/usr/lib/\*/libUnion.so|d; \|rm -rf debian/kde-style-union/usr/include/|d; \|rm -rf debian/kde-style-union/usr/lib/\*/cmake/|d' debian/rules
! grep -q 'rm -.*kde-style-union' debian/rules
