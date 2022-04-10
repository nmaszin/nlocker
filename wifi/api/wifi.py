import subprocess
import shutil
import utils
import time
import os
from threading import Thread
from pathlib import Path

def relative(path):
    module_dir = Path(os.path.dirname(__file__))
    project_dir = module_dir.parent
    return str(project_dir / path)

@utils.to_list
def get_available_networks(interface):
    print(relative('configs/wpa_supplicant.conf'))

    data, _ = subprocess.Popen(['iwlist', interface, 'scan'], stdout=subprocess.PIPE).communicate()
    data = data.decode('utf-8').strip().split('\n')
    for line in data:
        if 'ESSID' in line:
            yield line.strip().split(':')[1][1:-1]

def connect(interface, ssid, password):
    with open(relative('./configs/wpa_supplicant.conf')) as f:
        data = f.read()

    data = data.replace('#SSID#', ssid)
    data = data.replace('#PASSWORD#', password)
    
    with open(relative('./tmp/wpa_supplicant.conf'), 'w') as f:
        f.write(data)

    shutil.move(relative('./tmp/wpa_supplicant.conf'), '/etc/wpa_supplicant/wpa_supplicant.conf')
    reconfigure(interface)

def reconfigure(interface):
    def thread_code():
        time.sleep(2)
        subprocess.call([relative('station_mode.sh')])

    Thread(target=thread_code).start()

