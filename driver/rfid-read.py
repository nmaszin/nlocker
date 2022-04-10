#!/usr/bin/env python3

import json
import RPi.GPIO as GPIO
from mfrc522 import SimpleMFRC522

try:
    reader = SimpleMFRC522()
    identifier, text = reader.read()
    print(identifier)
finally:
    GPIO.cleanup()
