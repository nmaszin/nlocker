import jwt from 'jsonwebtoken'
import moment from 'moment'
import { Router } from 'express'
import { flattenSelect } from '@/models'
import { controller } from '@/middlewares/controller'
import { validator } from '@/middlewares/validator'
import { jwtAuth, lockerPairingAuth, lockerAuth } from '@/middlewares/auth'
import Locker from '@/models/locker'
import LockerForm from '@/forms/locker'
import Rfid from '@/models/rfid'
import RfidForm from '@/forms/rfid'
import Opening from '@/models/opening'
import { isConnected, openLocker, getRfidFromLocker } from '@/services/lockersServer'

async function obtainLocker(req, res, next) {
    const id = parseInt(req.params.lockerId)
    const locker = await Locker.selectById(id)

    if (locker === undefined) {
        return res.status(404).send({
            message: `This locker does not exist`
        })
    }

    if (locker.data.ownerId !== req.user.id) {
        return res.status(403).send({
            message: `You don't have permissions to this resource`
        })
    }

    req.locker = locker
    next()
}

async function obtainRfid(req, res, next) {
    const rfidId = parseInt(req.params.rfidId)

    const rfid = await Rfid.selectById(rfidId)
    if (rfid === undefined) {
        return res.status(404).send({
            message: 'Locker with given id does not exist'
        })
    } else if (rfid.data.lockerId !== req.locker.id) {
        return res.status(403).send({
            message: 'This RFID does not belong to this locker'
        })
    }

    req.rfid = rfid
    next()
}


const router = Router()

router.get('/lockers',
    jwtAuth,
    controller(async (req, res) => {
        const userId = parseInt(req.user.id)
        const data = await Locker.selectByOwner(userId)

        res.send({
            data: data
                .map(flattenSelect)
                .map(locker => ({
                    ...locker,
                    connected: isConnected(locker)
                }))
        })
    })
)

router.get('/lockers/:lockerId(\\d+)',
    jwtAuth,
    obtainLocker,
    controller(async (req, res) => {
        res.send({
            data: {
                ...flattenSelect(req.locker),
                connected: isConnected(req.locker)
            }   
        })
    })
)

router.put('/lockers/:lockerId(\\d+)',
    jwtAuth,
    validator(LockerForm),
    obtainLocker,
    controller(async (req, res) => {
        const data = {
            ...req.locker.data,
            ...req.body
        }

        if (!await Locker.updateById(req.locker.id, data)) {
            return res.status(400).send({
                message: 'Could not update'
            })
        }

        res.status(200).send({ data })
    })
)


router.get('/lockers/pairing-token',
    jwtAuth,
    controller(async (req, res) => {
        const token = jwt.sign(
            { id: req.user.id, type: 'pair' },
            process.env.JWT_SECRET,
            { expiresIn: 300 }
        )

        res.send({ token })
    })
)

router.post('/lockers',
    lockerPairingAuth,
    validator(LockerForm),
    controller(async (req, res) => {
        const data = {
            name: req.body.name,
            ownerId: req.user.id,
            creationTime: moment().format('YYYY-MM-DD HH:mm:ss')
        }

        const id = await Locker.insert(data)
        if (id === undefined) {
            return res.status(400).send({
                message: 'Could not add new locker'
            })
        }

        const token = jwt.sign(
            { id, type: 'locker' },
            process.env.JWT_SECRET,
        )

        return res.status(201).send({
            data: {
                id,
                token,
                ...data,
            }
        })
    })
)

router.get('/lockers/:lockerId(\\d+)/rfids',
    jwtAuth,
    obtainLocker,
    controller(async (req, res) => {
        const data = (await Rfid.selectByLocker(req.locker.id))
            .map(rfid => ({
                id: rfid.id,
                name: rfid.data.name,
                creationTime: rfid.data.creationTime
            }));

        res.status(200).send({ data })
    })
)

router.get('/lockers/:lockerId(\\d+)/rfids/:rfidId(\\d+)',
    jwtAuth,
    obtainLocker,
    obtainRfid,
    controller(async (req, res) => {
        res.status(200).send({
            data: {
                id: req.rfid.id,
                name: req.rfid.data.name,
                creationTime: req.rfid.creationTime
            }
        })
    })
)

router.post('/lockers/:lockerId(\\d+)/rfids',
    jwtAuth,
    validator(RfidForm),
    obtainLocker,
    controller(async (req, res) => {
        let value;
        try {
            value = await getRfidFromLocker(req.locker)
        } catch (e) {
            return res.status(503).send({
                message: 'Locker is not connected to server'
            })
        }

        const data = {
            name: req.body.name,
            value,
            lockerId: req.locker.id,
            creationTime: moment().format('YYYY-MM-DD HH:mm:ss')
        }

        const id = await Rfid.insert(data)
        if (id === undefined) {
            return res.status(400).send({
                message: 'Could not assign a new RFID tag to this locker'
            })
        }

        res.status(201).send({
            data: {
                id,
                name: data.name,
                creationTime: data.creationTime
            }
        })
    })
)

router.delete('/lockers/:lockerId(\\d+)/rfids/:rfidId(\\d+)',
    jwtAuth,
    obtainLocker,
    obtainRfid,
    controller(async (req, res) => {
        if (!await Rfid.deleteById(req.params.rfidId)) {
            res.status(400).send({
                message: 'Could not delete'
            })
        }

        res.status(200).send({})
    })
)


router.get('/lockers/:lockerId(\\d+)/openings',
    jwtAuth,
    obtainLocker,
    controller(async (req, res) => {
        const data = await Opening.selectByLocker(req.locker.id)
        res.status(200).send({
            data: data.map(flattenSelect)
        })
    })
)

router.post('/lockers/:lockerId(\\d+)/openings',
    jwtAuth,
    obtainLocker,
    controller(async (req, res) => {
        try {
            await openLocker(req.locker)
        } catch (e) {
            return res.status(503).send({
                message: 'Locker is not connected to the server'
            })
        }

        const time = moment().format('YYYY-MM-DD HH:mm:ss')
        const data = { time, lockerId: req.locker.id }
        await Opening.insert(data)
        res.status(201).send({})
    })
)

router.post('/lockers/:lockerId(\\d+)/openings/rfids/:rfidId(\\d+)',
    lockerAuth,
    obtainLocker,
    obtainRfid,
    controller(async (req, res) => {
        try {
            await openLocker(req.locker)
        } catch (e) {
            return res.status(503).send({
                message: 'Locker is not connected to the server'
            })
        }


        const time = moment().format('YYYY-MM-DD HH:mm:ss')
        const data = { time, lockerId: req.locker.id, rfidId: req.rfid.id }
        await Opening.insert(data)
        res.status(201).send({})
    })
)

export default router
