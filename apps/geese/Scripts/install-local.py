#!/usr/bin/env python3
"""Replace the local Geese app and verify that its icon choice is preserved."""
import argparse
from pathlib import Path
import plistlib
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'build.noindex/Geese.app'
DESTINATION = Path('/Applications/Geese.app')
DOMAIN = 'local.tim.geese'


def run(*args, check=True):
    return subprocess.run([str(a) for a in args], capture_output=True, text=True, check=check)


def icon_preference():
    result = run('defaults', 'read', DOMAIN, 'iconStyle', check=False)
    return result.stdout.strip() if result.returncode == 0 else None


def install(backup):
    assert plistlib.loads((SOURCE / 'Contents/Info.plist').read_bytes())['CFBundleIdentifier'] == DOMAIN
    run('codesign', '--verify', '--deep', '--strict', SOURCE)
    if not backup.exists():
        backup.parent.mkdir(parents=True, exist_ok=True)
        run('ditto', '-c', '-k', '--sequesterRsrc', '--keepParent', DESTINATION, backup)
    for pid in run('pgrep', '-x', 'Geese', check=False).stdout.split():
        if run('ps', '-p', pid, '-o', 'comm=', check=False).stdout.strip() == str(DESTINATION / 'Contents/MacOS/Geese'):
            run('kill', '-TERM', pid)
            for _ in range(40):
                if run('kill', '-0', pid, check=False).returncode:
                    break
                time.sleep(.1)
            else:
                raise RuntimeError('Geese did not quit')
    # Read after exit so the most recent user selection has been saved.
    previous_icon = icon_preference()
    run('ditto', SOURCE, DESTINATION)
    run('codesign', '--verify', '--deep', '--strict', DESTINATION)
    if icon_preference() != previous_icon:
        raise RuntimeError('Icon preference changed during installation')
    # This is a diagnostic value, not the Accessibility permission itself.
    run('defaults', 'delete', DOMAIN, 'lastAppAccessibilityGranted', check=False)
    run('open', DESTINATION)
    for _ in range(50):
        state = run('defaults', 'read', DOMAIN, 'lastAppAccessibilityGranted', check=False)
        if state.returncode == 0:
            if state.stdout.strip() != '1':
                raise RuntimeError('Installed Geese reports Accessibility is not enabled')
            break
        time.sleep(.2)
    else:
        raise RuntimeError('Geese did not report its startup state')
    if icon_preference() != previous_icon:
        raise RuntimeError('Icon preference changed when Geese reopened')
    print(f'Installed Geese; icon preference preserved: {previous_icon or "default (not set)"}. Accessibility remains enabled.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--backup', type=Path, required=True, help='Backup zip outside the app bundle')
    args = parser.parse_args()
    install(args.backup.resolve())
