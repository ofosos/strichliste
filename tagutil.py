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
    print("Detected UID:")

    (error, uid) = rdr.anticoll()
   	print(uid)

rdr.cleanup()
