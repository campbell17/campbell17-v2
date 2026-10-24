Geese — version 0.6.0

USE

Open /Applications/Geese.app. If needed, use the title-bar settings cog > Accessibility Settings
and enable Geese in System Settings > Privacy & Security > Accessibility.
Builds reuse a persistent local signing certificate so updates keep the same
Accessibility identity. Changing from the previous ad-hoc signature requires
one approval. Normal updates do not reset that permission.

Click + to add a running app. Apps appear in a four-column card grid. Hover a card and click X to remove it.
Every app in the list participates. All its eligible windows move; there
are no individual window selections. App choices are saved.

Click a desktop to move the listed apps' windows there. The bird marks
desktops containing selected movable windows; the tint marks the desktop holding all selected movable windows.
That destination is disabled. Other monitors’ visible desktops remain
available, and a split flock leaves all destinations available. Use the smaller named display tiles beside the desktops for another monitor. Right-click a desktop
to rename its label inside Geese.

Control-Option-Command-G shows or hides Geese by default. Choose Keyboard Shortcut
in either settings menu to record and save your own combination, or reset the default. Left-clicking the menu bar
bird also toggles the window; right-click or Control-click opens its settings. Escape hides it.
Pin window, Follow windows, Refresh, Accessibility Settings, and Quit are in
the title-bar settings cog menu. Check for Updates is also available there
and in the menu bar icon’s right-click menu. Geese checks for updates every hour
and asks before installing them. Pin window keeps Geese above other windows; it defaults to off
and your choice is saved.
After a migration, Geese stays open and comes to the front.
Opening the application icon also shows the window. Geese appears in the Dock and Command-Tab only while its main window is
open. Closing it, pressing Escape, or toggling it closed removes that entry. The menu bar icon and shortcut remain available.
Geese remembers the main window’s size and position when you close and reopen it,
including after quitting and restarting the app.

Minimized windows move with the flock and stay minimized. Full-screen and
multi-desktop windows are skipped. Leave full screen to include them. Set Dock > Options > Assign To > None
for apps you want to move freely. Closed apps are remembered but not launched.
Failed moves are reported; successful moves are not rolled back.

BUILD AND TEST

Run ./build.sh with Xcode command-line tools installed. Sparkle 2.10.0 is
included in Vendor.noindex/Sparkle under its included license. The output is a
locally certificate-signed build.noindex/Geese.app for the current CPU architecture, targeting
macOS 14 or later. It is tested on this Mac with macOS 26.7.1.

Scripts/sign.py reuses the signing keychain and identity stored privately at
~/Library/Application Support/Geese/Signing. Preserve that folder: replacing
the signing identity can require Accessibility approval again. The script
fails if saved signing state is incomplete rather than silently replacing it.

build.noindex/Geese.app/Contents/MacOS/Geese --self-test
build.noindex/Geese.app/Contents/MacOS/Geese --diagnose
build.noindex/Geese.app/Contents/MacOS/Geese --integration-test
build.noindex/Geese.app/Contents/MacOS/Geese --cross-process-test
build.noindex/Geese.app/Contents/MacOS/Geese --switch-test

The integration checks move only their own temporary windows and restore
them. The switch test visibly switches desktops and returns to the original.
The revised switch test requires real workspace-change notifications rather
than trusting the desktop ID alone. The exact post-migration Mission Control
symptom still needs a visual check with the installed app after access renewal.

IMPLEMENTATION

AppKit/SwiftUI and Accessibility provide the app and window discovery.
Private SkyLight APIs enumerate desktop IDs and submit asynchronous window
moves through SLSBridgedMoveWindowsToManagedSpaceOperation. The older
compatibility-workspace move is used only if that operation is unavailable.
These private APIs can change in future macOS updates.

Desktop switching first activates a verified app window on the destination,
letting macOS jump directly there in one transition. If app-based switching
is disabled in Desktop & Dock or the jump fails, Geese falls back to native
HID Control-Arrow events. It does not use the
bookkeeping-only CGSManagedDisplaySetCurrentSpace call, which can leave Dock
and Mission Control out of sync. Mission Control's normal keyboard shortcuts
must be enabled. Geese waits for native workspace notifications after each step.

References:
https://github.com/Hammerspoon/hammerspoon/tree/master/extensions/spaces
https://github.com/Hammerspoon/hammerspoon/pull/3889
https://github.com/cehbz/spacekit/blob/main/cmd/spaceswitch/native.go
https://github.com/michaeltorbert/spaces-manager

Build output stays inside build.noindex to keep duplicate development apps
out of Spotlight. Keep the installed app at /Applications/Geese.app. Store
any future backups as archives, not loose .app bundles.

Window frame persistence was verified across two processes. Accessibility
permission was verified with the installed GUI app before and after installing
a changed, certificate-signed build, then again after restoring the final build.
No permission reset or additional approval was used during those updates.

SHARING AND REMOTE UPDATES

Distribution/Install.txt contains first-launch instructions. Releases/Geese.dmg
is the shareable installer. It includes the app and an Applications shortcut.
This build is not Apple-notarized; recipients may need Privacy & Security >
Open Anyway on first launch, then Accessibility approval. It requires Apple
silicon. App choices and window information remain local.

The installer and update feed use the same site repo as Ice
Watch: campbell17/campbell17-v2. Geese has its own /apps/geese/ folder and
its own Sparkle Ed25519 update key, stored in the login Keychain under account
geese. Its public key is in Info.plist; the private key is never published.
The code-signing certificate and Sparkle update key are different keys and
both must be preserved when moving release builds to another Mac.

Prepare a release using a clean, separate clone of the site repository:

python3 Scripts/release.py --site /absolute/path/to/site-clone

Preparation builds the app, packages it, signs the update archive, generates
appcast.xml in the site clone. It increments
BUILD_NUMBER past the latest published build and does not commit or push.
After reviewing the prepared files, explicitly publish with:

python3 Scripts/release.py --site /absolute/path/to/site-clone --publish

Publishing commits and pushes public/apps/geese/ and the app source in apps/geese/.
The site deployment must finish before these URLs are available:
https://www.campbell17.com/apps/geese/install/Geese.dmg
https://www.campbell17.com/apps/geese/appcast.xml

Raise CFBundleShortVersionString in Info.plist when changing the display
version. BUILD_NUMBER is the increasing number Sparkle uses to compare updates.
The script requires the existing Geese signing certificate and Sparkle key.
Never create replacement keys to bypass a missing key error.

Release validation: the site production build passed; Sparkle detected build 4
from the prepared feed using an older host version. The archive signature
verified and a changed archive was rejected. The disk image checksum passed.
The installed build ran with Accessibility still granted. The release is published. Public archive and installer hashes match the
tested artifacts, and Sparkle detected build 4 through the live HTTPS feed.
A complete Sparkle download/install cycle has not yet been tested against
the public site.

Published site commit: e5cae8d2116bb6922e9f99425e78e955da719782.
Vercel production deployment completed successfully on October 19, 2026.

The standalone download webpage was removed; use the direct installer link.

Version 0.4.1 verification: an isolated fixture migrated from the current
desktop to Desktop 5 with exactly one native workspace-change notification.
The completion callback left the Geese test window visible, key, and owned by
the frontmost application. The fixture and original desktop were restored.

APPEARANCE

The supplied Geese artwork is included unchanged under Assets/Source.
The dark purple icon is the default bundle icon. App icon > Dark or Light
in either settings menu changes the Dock and Command-Tab icon immediately;
the choice is remembered after restarting. Finder and the installer use the
default dark bundle icon. The signed application bundle is never modified
when changing icons.

The menu bar uses the supplied white goose as a macOS template image, so it
remains visible in light and dark menu bars. Controls use the artwork’s purple
(#1b1464) and orange (#f7931e), with a lighter purple for dark mode contrast.

Version 0.5.0 includes the direct desktop jump and foreground behavior from
0.4.1 and removes the old view action that hid the window after migration.

Version 0.5.1 changes the headings to “Fly these geese…” and “To this pond:”.
App icon menus use dedicated 20-point previews, rendered at 40px on Retina,
rather than allowing native menus to use the full-size application artwork.

Version 0.5.2 uses appgeese-menu-icon-alt.svg for the menu bar, sized to
18 points high with its original aspect ratio and Retina artwork.

Version 0.5.3 reapplies the saved app icon after creating the Dock entry,
after the next run-loop cycle, and when Geese becomes active. Updates must
keep the existing iconStyle preference; the dark icon is only the default
when no preference exists. Local installs must verify the saved choice
before and after replacing the app, without changing it.

For local installs, use Scripts/install-local.py --backup /path/to/backup.zip.
It checks the icon preference after Geese exits, after replacing the bundle,
and after reopening, and fails if the choice changed. It never resets it.

Version 0.5.4 discovers selected apps’ windows across all desktops, including
when Geese starts on a different desktop. Discovery combines current AX
windows, validated cached references, bounded AX remote-object discovery,
and WindowServer membership for windows without an AX reference. Movement
rechecks window ownership, desktop membership, and minimized state.
A flock on the other display determines the initial display selection.

Run Tests/off-desktop.sh after ./build.sh to test fresh-process discovery,
bring-here movement, gathering windows from several desktops and monitors,
closed-window removal, and moving minimized windows while leaving unselected windows untouched. It creates
and removes only its own fixture windows and keeps the current desktop.

Version 0.5.5 replaces dark, light, and menu artwork with the October 23
SVG exports. Both menu and desktop flock markers use the new silhouette.
The existing app icon preference is retained.

VERSION 0.6.0 — HEADER AND FOOTER

The main window uses a tinted native toolbar with the selected app icon and
Geese title centered, native window controls, and a system settings gear.
A matching full-width footer shows the flock's actual desktop, split flock,
movement progress, or errors. A skipped window shows its app and reason;
click the footer notice for the full list and instructions. "All together
now." appears only when all movable windows are
on one desktop and no windows are skipped. The tint adapts to dark mode.
The app grid uses a compact native overlay scrollbar on the window's right
edge, with its card padding applied only to the scroll content. The scrollbar
fades when idle. --diagnose includes app names and reasons for skipped
windows, without printing window titles or moving anything.

SOURCE IN GIT

The complete build source lives at apps/geese in campbell17/campbell17-v2.
It includes the required Sparkle framework, tools, and license. Run ./build.sh
from that directory. Debug symbols and Sparkle’s sample application are not
needed to build and are excluded. Build output and local backups are ignored.
Signing keys and the private signing keychain remain outside the repository.

Version 0.6.0 also adds a Reopen button for closed apps, moves minimized windows
without restoring them, ignores inactive Claude helper windows, and adds desktop
destinations to the right-click menu. That menu opens using native status-bar
positioning and refreshes desktop data without a blocking full window scan.
Custom keyboard shortcuts persist across launches and updates.
