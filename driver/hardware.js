const util = require('util')
const exec = util.promisify(require('child_process').exec);

exports.openDoor = () => exec('./open.py')

exports.readRfid = () => new Promise(async (resolve, reject) => {
    let { stdout, stderr } = await exec('./rfid-read.py')
    stdout = stdout.trim()
    const err = stderr.length > 0 || stdout.length == 0
    const token = stdout

    if (err) {
        reject()
    } else {
        resolve(token)
    }
})

exports.sleep = duration => new Promise(resolve => setInterval(resolve, duration))

