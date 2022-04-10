import jwt from 'jsonwebtoken'
import { Router } from 'express'
import { controller } from '@/middlewares/controller'
import { validator } from '@/middlewares/validator'
import RegisterForm from '@/forms/register'
import User from '@/models/user'

const router = Router()

router.post('/register',
    validator(RegisterForm),
    controller(async (req, res) => {
        const id = await User.insert(req.body)
        if (id === undefined) {
            return res.status(400).send({
                message: 'Could not add record to database'
            })
        }

        const data = {
            id,
            email: req.body.email
        }

        return res.status(201).send({ data })
    })
)

export default router
