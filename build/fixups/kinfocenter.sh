# kinfocenter 6.8: find_package(Qt6 ... Graphs) (charts of the energy page) -> build with qt6-graphs-dev, run with the QML module
sed -i 's/^Build-Depends: debhelper-compat (= 13),$/Build-Depends: debhelper-compat (= 13),\n               qt6-graphs-dev, qt6-quick3d-dev,/' debian/control
sed -i '/^Package: kinfocenter$/,/^$/ s/^Depends: libkf6kcmutils-bin,$/Depends: libkf6kcmutils-bin,\n         qml6-module-qtgraphs,/' debian/control
grep -q 'qt6-quick3d-dev' debian/control && grep -q 'qml6-module-qtgraphs' debian/control
