#!/usr/bin/env python3
from pirc522 import RFID
import signal
import time

rdr = RFID()
util = rdr.util()
# Set util debug to true - it will print what's going on
util.debug = True

print("Waiting for tag...")
rdr.wait_for_tag()

# Request tag
(error, data) = rdr.request()
if not error:
    print("\nDetected: " + format(data, "02x"))
    print("Detected UID:")

    (error, uid) = rdr.anticoll()
    if not error:
        # Print UID
        print("Card read UID: "+str(uid[0])+","+str(uid[1])+","+str(uid[2])+","+str(uid[3]))
    else:
        print("Error reading card:")
        print(error)
rdr.cleanup()
