require('dotenv').config()
const { WebSocket } = require('ws')
const LCD = require('raspberrypi-liquid-crystal');
const { openDoor, readRfid } = require('./hardware.js')
const { EventEmitter } = require('events');


function openDoorCallback(err, token) {
    if (!err) {
        openDoor()
    }
}


const rfid = new EventEmitter()
rfid.on('read', openDoorCallback)


const lcd = new LCD(1, 0x27, 16, 2)


process.on('SIGINT', () => {
    lcd.clearSync();
    process.exit(0)
});


(async () => {
    await lcd.begin()
    await lcd.clear()
    await lcd.printLine(0, ' NLocker v1.1.2 ')
    await lcd.printLine(1, '     CLOSED     ')

    const socket = new WebSocket(process.env.WS_URL)
    socket.on('open', () => {
        socket.send(JSON.stringify({
            type: 'auth',
            token: process.env.AUTH_TOKEN
        }))
    })

    socket.on('message', async text => {
        try {
            const data = JSON.parse(text)
            if (data.type === 'read-rfid') {
                await lcd.printLine(1, '   TAP A CARD   ')

                rfid.on('read', async (err, token) => {
                    if (err) {
                        socket.send(JSON.stringify({ type: 'error' }))
                    } else {
                        socket.send(JSON.stringify({ type: 'readed-rfid', value: token }))
                    }

                    await lcd.printLine(1, '     CLOSED     ')
                    rfid.on(openDoorCallback)
                })

            } else if (data.type === 'open') {
                await lcd.printLine(1, '     OPENED     ')

                socket.send(JSON.stringify({ type: 'opened' }))
                await openDoor()

                lcd.printLine(1, '     CLOSED     ')
            }
        } catch (e) {
            console.log(e)
        }
    })

    while (true) {
        try {
            const token = await readRfid()
            rfid.emit('read', false, token)
        } catch (e) {
            rfid.emit('read', true)
        }
    }
})()

