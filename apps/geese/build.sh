#!/bin/zsh
set -eu
cd "${0:A:h}"
geese_build="$PWD/build.noindex"
geese_app="$geese_build/Geese.app"
mkdir -p "$geese_build" "$geese_app/Contents/MacOS" "$geese_app/Contents/Resources" "$geese_app/Contents/Frameworks"
xcrun clang -mmacosx-version-min=14.0 -fobjc-arc -O2 -c Sources/Bridge.m -o "$geese_build/Bridge.o"
xcrun swiftc -target "$(uname -m)-apple-macos14.0" -swift-version 5 -O -import-objc-header Sources/Bridge.h Sources/Model.swift Sources/Views.swift Sources/Updates.swift Sources/main.swift "$geese_build/Bridge.o" -framework Cocoa -framework SwiftUI -framework ApplicationServices -framework Carbon -F Vendor.noindex/Sparkle -framework Sparkle -Xlinker -rpath -Xlinker @executable_path/../Frameworks -o "$geese_app/Contents/MacOS/Geese"
cp Info.plist "$geese_app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $(cat BUILD_NUMBER)" "$geese_app/Contents/Info.plist"
ditto Vendor.noindex/Sparkle/Sparkle.framework "$geese_app/Contents/Frameworks/Sparkle.framework"
cp Assets/Geese.icns Assets/GeeseLight.icns Assets/GeeseMenu.png Assets/GeeseMenu@2x.png Assets/GeeseMenuAlt.png Assets/GeeseMenuAlt@2x.png "$geese_app/Contents/Resources/"
python3 Scripts/sign.py "$geese_app"
print "Built $geese_app"
