import { WebSocketServer } from 'ws'
import jwt from 'jsonwebtoken'

const connections = {}
const server = new WebSocketServer({ port: process.env.WS_PORT })

server.on('connection', socket => {
    socket.on('message', text => {
        try {
            const data = JSON.parse(text)
            console.log('Received', data)
            if (data.type === 'auth') {
                jwt.verify(data.token, process.env.JWT_SECRET, (err, payload) => {
                    if (err || payload.type !== 'locker') {
                        socket.send(JSON.stringify({ type: 'auth-error' }))
                    } else {
                        connections[payload.id] = socket
                        socket.on('message', () => {})
                        socket.on('close', () => delete connections[payload.id])
                    }
                })
            }
        } catch (e) {
            // ignore
        }
    })
})

export const openLocker = locker => new Promise((resolve, reject) => {
    const socket = connections[locker.id]
    if (socket === undefined) {
        reject('Locker has not either connected or authenticated to server yet')
    }

    socket.send(JSON.stringify({ type: 'open' }))
    socket.on('close', () => reject('Locker disconnected'))
    socket.on('message', text => {
        try {
            const data = JSON.parse(text)
            if (data.type === 'opened') {
                resolve()
            }
        } catch (e) {
            reject('Invalid response from locker')
        }
    })
})

export const getRfidFromLocker = locker => new Promise((resolve, reject) => {
    const socket = connections[locker.id]
    if (socket === undefined) {
        reject('Locker has not either connected or authenticated to server yet')
    }

    socket.send(JSON.stringify({ type: 'read-rfid' }))
    socket.on('close', () => reject('Locker disconnected'))
    socket.on('message', text => {
        try {
            const data = JSON.parse(text)
            if (data.type === 'readed-rfid') {
                resolve(data.value)
            } else {
                reject('Invalid response from locker')
            }
        } catch (e) {
            reject('Invalid response from locker')
        }
    })
})

export const isConnected = locker => connections[locker.id] !== undefined

export const resetLocker = locker => new Promise((resolve, reject) => {
    const socket = connections[locker.id]
    if (socket === undefined) {
        reject('Locker has not either connected or authenticated to server yet')
    }

    socket.send(JSON.stringify({ type: 'reset' }))
    socket.on('close', () => reject('Locker disconnected'))
    socket.on('message', text => {
        try {
            const data = JSON.parse(text)
            if (data.type === 'ok') {
                resolve()
            }
        } catch (e) {
            reject('Invalid response from locker')
        }
    })
})
