import { Router } from 'express'
import { controller } from '@/middlewares/controller'
import Database from '@/models/db'

const router = Router()

router.post('/db',
    controller(async (req, res) => {
        await Database.initialize()

        res.status(200).send({
            message: 'Database succesfully initialized'
        })
    })
)

router.put('/db',
    controller(async (req, res) => {
        await Database.deinitialize()
        await Database.initialize()

        res.status(200).send({
            message: 'Database succesfully reinitialized'
        })
    })
)

router.delete('/db',
    controller(async (req, res) => {
        await Database.deinitialize()

        res.status(200).send({
            message: 'Database succesfully deinitialized'
        })
    })
)

export default router

