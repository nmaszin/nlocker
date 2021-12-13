#!/usr/bin/env python3

import os
import sys
import time

def led_init():
    os.system('echo none >/sys/class/leds/led0/trigger')

def led_on():
    os.system('echo 1 >/sys/class/leds/led0/brightness')

def led_off():
    os.system('echo 0 >/sys/class/leds/led0/brightness')

def main():
    led_init()
    led_off()
    while True:
        led_on()
        time.sleep(0.5)
        led_off()
        time.sleep(0.5)

if __name__ == '__main__':
    main()

