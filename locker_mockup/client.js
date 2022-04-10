require('dotenv').config()
const { WebSocket } = require('ws')

function generate_token(length){
    var a = "1234567890".split("");
    var b = [];  
    for (var i=0; i<length; i++) {
        var j = (Math.random() * (a.length-1)).toFixed(0);
        b[i] = a[j];
    }
    return b.join("");
}

const socket = new WebSocket(process.env.WS_URL)

const sleep = duration => new Promise(resolve => setTimeout(resolve, duration))

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
				await sleep(3000)
				const message = JSON.stringify({ type: 'readed-rfid', value: generate_token(10) })
				socket.send(message)
		} else if (data.type === 'open') {
			const message = JSON.stringify({ type: 'opened' })
			socket.send(message)
		}
	} catch (e) {
		// Ignore
	}
})

