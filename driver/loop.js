const { readRfid, openDoor, sleep } = require('./hardware.js');

(async () => {
	while (true) {
		try {
			const token = await readRfid()
			await openDoor()
		} catch (e) {

		}

		sleep(100)
	}
})()
