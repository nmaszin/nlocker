import { Router } from 'express'
import { loadDirectoryModules } from '@/utils/directoryLoader';
import { flattenSelect } from '@/models'
import { controller } from '@/middlewares/controller'
import { validator } from '@/middlewares/validator'
import { jwtAuth } from '@/middlewares/auth'
import { atLeastReader, atLeastWriter } from '@/middlewares/roles'

// The following function load all endpoints routers and bind them into a new one
// I assume that all files in current directory (except current file) are endpoints files
export async function loadAllEndpoints() {
    const router = Router()
    const routers = await loadDirectoryModules(__dirname, ['index.js'])
    routers.forEach(r => router.use(r))
    return router
}

// Function for automatic generation of typical (for this application) endpoints
export function generateEndpoint(path, model, form) {
    const router = Router()

    router.get(path,
        jwtAuth,
        atLeastReader,
        controller(async (req, res) => {
            const data = await model.selectAll()
            res.send({
                data: data.map(flattenSelect)
            })
        })
    )

    router.get(`${path}/:id(\\d+)`,
        jwtAuth,
        atLeastReader,
        controller(async (req, res) => {
            const id = parseInt(req.params.id)
            const data = await model.selectById(id)
            if (data === undefined) {
                return res.status(404).send({
                    message: `This ${model.name.toLowerCase()} does not exist`
                })
            }

            res.status(200).send({
                data: flattenSelect(data)
            })
        })
    )

    router.post(path,
        jwtAuth,
        atLeastWriter,
        validator(form),
        controller(async(req, res) => {
            const id = await model.insert(req.body)
            if (id === undefined) {
                return res.status(400).send({
                    message: 'Could not add record to database'
                })
            }

            const data = { id, ...req.body }
            res.status(201).send({ data })
        })
    )

    router.put(`${path}/:id(\\d+)`,
        jwtAuth,
        atLeastWriter,
        validator(form),
        controller(async (req, res) => {
            const id = parseInt(req.params.id)
            const data = { id, ...req.body }
            if (!await model.updateById(id, req.body)) {
                return res.status(404).send({
                    message: `${model.name} with given id does not exist`
                })
            }

            res.status(200).send({ data })
        })
    )

    router.delete(`${path}/:id(\\d+)`,
        jwtAuth,
        atLeastWriter,
        controller(async (req, res) => {
            const id = parseInt(req.params.id)
            if (!await model.deleteById(id)) {
                return res.status(404).send({
                    message: `This ${model.name.toLowerCase()} does not exist`
                })
            }

            res.status(200).send({})
        })
    )

    return router
}
