export function jsonParsingError(err, req, res, next) {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        res.status(400).send({ message: "JSON parsing error" })
    } else {
        next()
    }
}

export function notFoundRoute(req, res) {
    res.status(404).send({
        message: 'Unknown route'
    })
}

export function catchAllExceptions(controller) {
    return async (req, res, next) => {
        try {
            await controller(req, res, next)
        } catch (err) {
            res.status(err.status || 500).send({
                message: err.message
            })
        }
    }
}

