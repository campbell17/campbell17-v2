#!/usr/bin/env python3
"""Sign every local Geese build with the same private certificate."""
import hashlib
import json
import os
from pathlib import Path
import secrets
import shlex
import subprocess
import sys
import tempfile

STATE = Path.home() / 'Library/Application Support/Geese/Signing'
CONFIG = STATE / 'identity.json'
KEYCHAIN = STATE / 'Geese-signing.keychain-db'
PASSWORD = STATE / 'keychain-password'
IDENTIFIER = 'local.tim.geese'


def run(args):
    result = subprocess.run([str(arg) for arg in args], capture_output=True, text=True)
    if result.returncode:
        # Do not include arguments: some Security CLI operations take a password.
        raise RuntimeError(f'{Path(args[0]).name}: {result.stderr.strip() or "operation failed"}')
    return result.stdout


def setup():
    STATE.mkdir(parents=True, exist_ok=True, mode=0o700)
    STATE.chmod(0o700)
    if CONFIG.exists():
        config = json.loads(CONFIG.read_text())
        if not KEYCHAIN.exists() or not PASSWORD.exists():
            raise RuntimeError('The saved signing keychain is missing. Restore it; do not create a replacement identity.')
        return config
    if KEYCHAIN.exists() or PASSWORD.exists():
        raise RuntimeError('Signing setup is incomplete. Preserve the existing keychain and finish setup before building.')

    password = secrets.token_urlsafe(36)
    PASSWORD.write_text(password)
    PASSWORD.chmod(0o600)
    original_search = shlex.split(run(['/usr/bin/security', 'list-keychains', '-d', 'user']))
    try:
        run(['/usr/bin/security', 'create-keychain', '-p', password, KEYCHAIN])
        run(['/usr/bin/security', 'unlock-keychain', '-p', password, KEYCHAIN])
        with tempfile.TemporaryDirectory(prefix='setup-', dir=STATE) as temporary:
            folder = Path(temporary)
            config_file = folder / 'certificate.cnf'
            config_file.write_text('''[req]
prompt = no
distinguished_name = subject
x509_extensions = signing
[subject]
CN = Geese Local Code Signing
O = Geese Local Development
[signing]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature
extendedKeyUsage = critical,codeSigning
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid
''')
            private_key = folder / 'key.pem'
            certificate = folder / 'certificate.pem'
            public_der = folder / 'certificate.der'
            package = folder / 'identity.p12'
            package_password = secrets.token_urlsafe(36)
            pass_file = folder / 'package-password'
            pass_file.write_text(package_password)
            pass_file.chmod(0o600)
            run(['/usr/bin/openssl', 'req', '-new', '-newkey', 'rsa:3072', '-nodes', '-x509',
                 '-days', '3650', '-config', config_file, '-keyout', private_key, '-out', certificate])
            private_key.chmod(0o600)
            run(['/usr/bin/openssl', 'x509', '-in', certificate, '-outform', 'DER', '-out', public_der])
            fingerprint = hashlib.sha1(public_der.read_bytes()).hexdigest().upper()
            run(['/usr/bin/openssl', 'pkcs12', '-export', '-inkey', private_key, '-in', certificate,
                 '-name', 'Geese Local Code Signing', '-out', package, '-passout', f'file:{pass_file}'])
            run(['/usr/bin/security', 'import', package, '-k', KEYCHAIN, '-P', package_password,
                 '-x', '-T', '/usr/bin/codesign'])
            run(['/usr/bin/security', 'set-key-partition-list', '-S', 'apple-tool:,apple:,codesign:',
                 '-s', '-k', password, KEYCHAIN])
            (STATE / 'certificate.der').write_bytes(public_der.read_bytes())
            config = {'certificate_sha1': fingerprint, 'identifier': IDENTIFIER}
            CONFIG.write_text(json.dumps(config, indent=2) + '\n')
            CONFIG.chmod(0o600)
            return config
    finally:
        # The Geese keychain is selected explicitly when signing; preserve the user's search list.
        current_search = shlex.split(run(['/usr/bin/security', 'list-keychains', '-d', 'user']))
        if current_search != original_search:
            run(['/usr/bin/security', 'list-keychains', '-d', 'user', '-s', *original_search])


def sign(app):
    config = setup()
    run(['/usr/bin/security', 'unlock-keychain', '-p', PASSWORD.read_text(), KEYCHAIN])
    valid = run(['/usr/bin/security', 'find-identity', '-v', '-p', 'codesigning', KEYCHAIN])
    if config['certificate_sha1'] not in valid:
        # Trust this local certificate only for signing code, in the user's trust domain.
        run(['/usr/bin/security', 'add-trusted-cert', '-r', 'trustRoot', '-p', 'codeSign',
             '-k', KEYCHAIN, STATE / 'certificate.der'])
    requirement = f'designated => identifier "{IDENTIFIER}" and certificate leaf = H"{config["certificate_sha1"]}"'
    original_search = shlex.split(run(['/usr/bin/security', 'list-keychains', '-d', 'user']))
    try:
        run(['/usr/bin/security', 'list-keychains', '-d', 'user', '-s', KEYCHAIN,
             *(path for path in original_search if path != str(KEYCHAIN))])
        run(['/usr/bin/codesign', '--force', '--sign', config['certificate_sha1'], '--keychain', KEYCHAIN,
             '--timestamp=none', '--requirements', '=' + requirement, app])
    finally:
        run(['/usr/bin/security', 'list-keychains', '-d', 'user', '-s', *original_search])
    run(['/usr/bin/codesign', '--verify', '--deep', '--strict', app])
    print('Signed Geese with its persistent local certificate.')


if __name__ == '__main__':
    try:
        if len(sys.argv) != 2:
            raise RuntimeError('Usage: sign.py /path/to/Geese.app')
        sign(Path(sys.argv[1]).resolve())
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
