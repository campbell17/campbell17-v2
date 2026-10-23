#!/usr/bin/env python3
"""Prepare a Geese release; only --publish commits and pushes it."""
import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
URL = 'https://www.campbell17.com/apps/geese/'
FOLDER = 'public/apps/geese'
SOURCE_FOLDER = 'apps/geese'


def run(*args, cwd=None):
    return subprocess.run([str(a) for a in args], cwd=cwd, check=True, text=True, capture_output=True).stdout.rstrip()


def prepare(site):
    if run('git', 'status', '--porcelain', cwd=site):
        raise RuntimeError('Publishing checkout has uncommitted changes. Review them before preparing another release.')
    run('git', 'pull', '--ff-only', cwd=site)
    releases = site / FOLDER
    releases.mkdir(parents=True, exist_ok=True)
    published = 0
    feed = releases / 'appcast.xml'
    if feed.exists():
        published = max(int(node.text) for node in ET.parse(feed).iter('{http://www.andymatuschak.org/xml-namespaces/sparkle}version'))
    number = max(int((ROOT / 'BUILD_NUMBER').read_text()), published + 1)
    (ROOT / 'BUILD_NUMBER').write_text(f'{number}\n')
    print(run(ROOT / 'build.sh'), flush=True)
    app = ROOT / 'build.noindex/Geese.app'
    archive = releases / f'Geese-{number}.zip'
    run('ditto', '-c', '-k', '--sequesterRsrc', '--keepParent', app, archive)
    installer = releases / 'install/Geese.dmg'
    installer.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='geese-dmg-', suffix='.noindex', dir=ROOT / 'build.noindex') as temporary:
        staging = Path(temporary)
        run('ditto', app, staging / 'Geese.app')
        (staging / 'Applications').symlink_to('/Applications')
        shutil.copy2(ROOT / 'Distribution/Install.txt', staging / 'Read Me First.txt')
        run('hdiutil', 'create', '-quiet', '-volname', 'Geese', '-srcfolder', staging, '-ov', '-format', 'UDZO', installer)
    sparkle = ROOT / 'Vendor.noindex/Sparkle/bin'
    print(run(sparkle / 'generate_appcast', '--account', 'geese', '--download-url-prefix', URL,
              '--maximum-versions', '3', '--maximum-deltas', '0', releases), flush=True)
    # Keep downloadable files beside the source for review and sharing after publication.
    artifacts = ROOT / 'Releases'
    artifacts.mkdir(exist_ok=True)
    for path in (archive, installer, feed):
        shutil.copy2(path, artifacts / path.name)
    source = site / SOURCE_FOLDER
    source.mkdir(parents=True, exist_ok=True)
    for name in ['Sources', 'Assets', 'Scripts', 'Tests']:
        shutil.copytree(ROOT / name, source / name, dirs_exist_ok=True, symlinks=True)
    for name in ['Info.plist', 'BUILD_NUMBER', 'README.txt', 'build.sh']:
        shutil.copy2(ROOT / name, source / name)
    (source / '.gitignore').write_text('build.noindex/\nbuild/\nReleases/\n__pycache__/\n.DS_Store\n')
    vendor = source / 'Vendor.noindex/Sparkle'
    vendor.mkdir(parents=True, exist_ok=True)
    for name in ['Sparkle.framework', 'bin']:
        shutil.copytree(ROOT / 'Vendor.noindex/Sparkle' / name, vendor / name, dirs_exist_ok=True, symlinks=True)
    for name in ['LICENSE', 'INSTALL', 'CHANGELOG']:
        shutil.copy2(ROOT / 'Vendor.noindex/Sparkle' / name, vendor / name)
    print(f'Prepared build {number}. Download after publication: {URL}install/Geese.dmg', flush=True)


def publish(site):
    changes = run('git', 'status', '--porcelain', '--untracked-files=all', cwd=site).splitlines()
    if not changes:
        raise RuntimeError('No prepared release to publish.')
    if any(not (line[3:].startswith(FOLDER + '/') or line[3:].startswith(SOURCE_FOLDER + '/')) for line in changes):
        raise RuntimeError('Unexpected changes in publishing checkout; nothing was committed.')
    run('git', 'add', '-A', '--', FOLDER, SOURCE_FOLDER, cwd=site)
    run('git', 'commit', '-m', f'Add Geese release {int((ROOT / "BUILD_NUMBER").read_text())}', '--', FOLDER, SOURCE_FOLDER, cwd=site)
    run('git', 'push', cwd=site)
    print(f'Published Geese source and release. Deployment must finish before {URL}install/Geese.dmg is updated.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--site', type=Path, required=True, help='Clean, separate clone of campbell17/campbell17-v2')
    parser.add_argument('--publish', action='store_true', help='Commit and push an already prepared release')
    args = parser.parse_args()
    site = args.site.resolve()
    if 'campbell17/campbell17-v2' not in run('git', 'remote', 'get-url', 'origin', cwd=site):
        parser.error('Expected campbell17/campbell17-v2 publishing checkout.')
    if args.publish:
        publish(site)
    else:
        prepare(site)
