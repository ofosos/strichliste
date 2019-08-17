#!/usr/bin/env python3

import argparse
import signal
import time

from pirc522 import RFID


parser = argparse.ArgumentParser(description='Read an RFID tag.')
parser.add_argument('--quiet', action='store_true')

args = parser.parse_args()

quiet = args.quiet

class RC522Reader:
    def __init__(self):
        self.reader = RFID()

    def force_read_id(self):
        while True:
            self.reader.wait_for_tag()
            (error, tag_type) = self.reader.request()
            if error:
                continue

            print("Tag detected")
            (error, uid) = self.read_uid()
            if error:
                continue

            card_uid = ''
            for part in uid:
                card_uid += ("%X" % part)

            return card_uid

    def read_uid(self):
        # https://www.nxp.com/docs/en/application-note/AN10927.pdf
        (error, uid) = self.reader.anticoll()
        if error:
            return error, None

        if uid[0] is not 0x88:
            return False, uid
        
        error = self.reader.select_tag(uid)  

        full_uid = uid[1:3]

        print("UID is not yet complete")
        (error, cl2) = self.read_cl2()
        if error:
            return error, None

        if cl2[0] is not 0x88:
            full_uid.extend(cl2)
            return False, full_uid

        full_uid.extend(cl2[1:3])
        (error, cl3) = self.read_cl3()
        if error:
            return error, None

        full_uid.extend(cl3)
        return False, full_uid

    def read_cl2(self):
        back_data = []
        serial_number = []

        serial_number_check = 0

        self.reader.dev_write(0x0D, 0x00)
        serial_number.append(0x95)
        serial_number.append(0x20)

        (error, back_data, back_bits) = self.reader.card_write(self.reader.mode_transrec, serial_number)
        if not error:
            if len(back_data) == 5:
                for i in range(4):
                    serial_number_check = serial_number_check ^ back_data[i]

                if serial_number_check != back_data[4]:
                    error = True
            else:
                error = True

        return error, back_data

    def read_cl3(self):
        back_data = []
        serial_number = []

        serial_number_check = 0

        self.reader.dev_write(0x0D, 0x00)
        serial_number.append(0x97)
        serial_number.append(0x20)

        (error, back_data, back_bits) = self.reader.card_write(self.reader.mode_transrec, serial_number)
        if not error:
            if len(back_data) == 5:
                for i in range(4):
                    serial_number_check = serial_number_check ^ back_data[i]

                if serial_number_check != back_data[4]:
                    error = True
            else:
                error = True

        return error, back_data


rdr = RC522Reader()
(error, uid) = rdr.read_uid()
if not error:
    print uid
