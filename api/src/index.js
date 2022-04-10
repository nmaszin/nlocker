import express from 'express'
import passport from '@/services/passport'
import { loadAllEndpoints } from '@/endpoints'
import { notFoundRoute, jsonParsingError } from '@/middlewares/errors'

(async () => {
    const app = express()
    app.use(express.json())
    app.use(jsonParsingError)
    app.use(express.urlencoded({ extended: false }))

    app.use(await loadAllEndpoints())
    app.use(notFoundRoute)
    
    passport()

    const port = process.env.PORT
    app.listen(port, '0.0.0.0', () => console.log(`Running on http://localhost:${port}`))    
})()
