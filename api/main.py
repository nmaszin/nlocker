#!/usr/bin/env python3

from flask import Flask, abort, request
import wifi

INTERFACE = 'wlan0'
PORT = 9997

app = Flask(__name__)

@app.route('/', methods=['GET'])
def list_available_networks():
    networks = wifi.get_available_networks(INTERFACE)

    return {
        'networks': networks
    }

@app.route('/', methods=['POST'])
def connect_to_network():
    ssid = request.json['ssid']
    password = request.json['password']
    wifi.connect(INTERFACE, ssid, password)

    return {
        'message': 'Check whether you were connected successfully after a while'
    }


def main():
    app.run(host='0.0.0.0', port=PORT)

if __name__ == '__main__':
    main()

