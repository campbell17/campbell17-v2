#!/bin/zsh
set -eu
cd "${0:A:h:h}"
geese_test="$PWD/build.noindex/off-desktop-test.noindex"
mkdir -p "$geese_test"
xcrun swiftc -swift-version 5 -import-objc-header Sources/Bridge.h Sources/Model.swift Tests/OffDesktop/main.swift build.noindex/Bridge.o -framework Cocoa -framework ApplicationServices -o "$geese_test/GeeseOffDesktopTest"
python3 - "$geese_test" <<'PY'
from pathlib import Path
import sys,shutil,plistlib
root=Path(sys.argv[1])
for name,identifier in [('Selected','local.tim.geese.off-desktop-fixture'),('Unselected','local.tim.geese.unselected-fixture')]:
    app=root/f'{name}.app/Contents'
    (app/'MacOS').mkdir(parents=True,exist_ok=True)
    shutil.copy2(root/'GeeseOffDesktopTest',app/'MacOS/Fixture')
    (app/'Info.plist').write_bytes(plistlib.dumps(dict(CFBundleExecutable='Fixture',CFBundleIdentifier=identifier,CFBundleName=f'Geese {name} test',CFBundlePackageType='APPL',LSUIElement=True)))
PY
"$geese_test/GeeseOffDesktopTest"
