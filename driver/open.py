#!/usr/bin/env python3

from RPi import GPIO
import time

PIN = 4
TIME = 3

GPIO.setmode(GPIO.BCM)
GPIO.setup(PIN, GPIO.OUT)
GPIO.output(PIN, 1)
time.sleep(TIME)
GPIO.output(PIN, 0)


