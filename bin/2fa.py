#!/usr/bin/env python

"""2fa.py, an easy wrapper for oathtool, to generate one-time passcodes.
Manages AES key storage and sequence counting.
"""

import os
import subprocess  # Requires Python 2.7
import argparse

OATHTOOL = '/usr/local/bin/oathtool'
KEY_DIR_SUFFIX = '.2fa'
KEY_DIRS = [os.path.join(os.path.realpath(os.path.dirname(__file__)),
                         KEY_DIR_SUFFIX),
            os.path.join(os.environ['HOME'], KEY_DIR_SUFFIX)]


def main(args):
    """
    Generate next one time passcode
    or create a new profile and generate the first passcode
    """
    mode = 'otp'
    keyname = args.profile
    directory = args.directory

    key, last_seq, directory = load_key(keyname, directory)
    if key is None or last_seq is None:
        # Create new key file if no data for the profile is found
        mode = 'addkey'

    if mode == 'otp':
        print(gen_otp(key, last_seq))
        save_key(keyname, directory, seq=last_seq+1)

    elif mode == 'addkey':
        key, seq = add_key(keyname, directory)
        if key:
            print('Your first OTP is: %s' % (gen_otp(key, seq)))
            save_key(keyname, directory, seq=seq+1)


def load_key(keyname, directory):
    """
    Load key and sequence data from the profile directory.
    returns key, seq, key_dir
    """
    key = None
    seq = None
    if directory is None:
        key_dirs = KEY_DIRS
    else:
        key_dirs = [directory]

    for key_dir in key_dirs:
        profile_dir = os.path.join(key_dir, keyname)
        if os.path.isdir(profile_dir):
            key_file = os.path.join(profile_dir, 'key')
            key = open(key_file).readline().strip()
            seq_file = os.path.join(profile_dir, 'seq')
            seq = int(open(seq_file).readline().strip())
            break
    return key, seq, key_dir


def save_key(keyname, directory, key=None, seq=None):
    """
    Save key and sequence data to the profile directory
    """
    if directory is None:
        key_dir = KEY_DIRS[-1]
    else:
        key_dir = directory

    if not os.path.exists(key_dir):
        os.mkdir(key_dir, 0o700)
    if not os.path.exists(os.path.join(key_dir, keyname)):
        os.mkdir(os.path.join(key_dir, keyname))
    if key:
        open(os.path.join(key_dir, keyname, 'key'), 'w').write(key)
    if seq is not None:
        open(os.path.join(key_dir, keyname, 'seq'), 'w').write(str(seq))


def add_key(keyname, directory):
    """
    Create a new key file based on the key provided by the server
    """
    print('Creating profile "%s".' % (keyname,))
    key = raw_input('Paste the shared AES key from SSO: ')
    key = key.strip().replace(' ', '')
    seq = 0
    save_key(keyname, directory, key=key, seq=seq)
    return key, seq


def check_oathtool_binary():
    """
    Make sure that oathtool is available
    """
    try:
        subprocess.check_output(["which", OATHTOOL])
    except subprocess.CalledProcessError:
        print("'oathtool' command not found!")
        print("Install it with: sudo apt-get install oathtool")
        exit(1)


def gen_otp(key, seq):
    """
    Generate next one time passcode
    """
    check_oathtool_binary()
    text = subprocess.check_output([OATHTOOL, '-c', str(seq), key])
    return text.strip().decode('utf-8')


def parse_args(argv):
    """
    Parse command line arguments
    """
    description = """
    Generates the next passcode in the sequence for the given profile name
    (will create a new profile on first use).
    """
    epilog = """
    When creating a new key '~/.2fa' will be used as default directory.
    When loading a key, '<script_path>/.2fa' will be attempted first
    and, after that, '~/.2fa'"""
    parser = argparse.ArgumentParser(description=description, epilog=epilog)
    parser.add_argument('profile', metavar='PROFILE', nargs='?',
                        default='default',
                        help='Profile name (\'%(default)s\' by default)')
    parser.add_argument('-d', '--directory',
                        help='Base directory to store profile data')
    args = parser.parse_args(argv)
    if args.directory:
        head, tail = os.path.split(args.directory)
        if tail != KEY_DIR_SUFFIX:
            args.directory = os.path.join(args.directory, KEY_DIR_SUFFIX)
    return args

if __name__ == "__main__":
    import sys
    args = parse_args(sys.argv[1:])
    main(args)
