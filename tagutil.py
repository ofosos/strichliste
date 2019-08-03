#!/usr/bin/env python3

import argparse
import signal
import time

from pirc522 import RFID


parser = argparse.ArgumentParser(description='Read an RFID tag.')
parser.add_argument('--quiet', action='store_true')

args = parser.parse_args()

quiet = args.quiet

rdr = RFID()
util = rdr.util()
# Set util debug to true - it will print what's going on
util.debug = True

if not quiet:
    print("Waiting for tag...")
rdr.wait_for_tag()

# Request tag
(error, data) = rdr.request()
if not error:
    if not quiet:
        print("\nDetected: " + format(data, "02x"))
        print("Detected UID:")

    (error, uid) = rdr.anticoll()
    if not error:
        # Print UID
        uid = (uid[0] << 24) + (uid[1] << 16) + (uid[2] << 8) + uid[3]
        print(str(uid))
    elif not quiet:
        print("ERROR reading card:")
        print(error)
rdr.cleanup()
