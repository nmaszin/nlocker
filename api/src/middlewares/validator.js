export function validator(form) {
    return async (req, res, next) => {
        const validationErrors = await form.validate(req.body)

        if (validationErrors !== undefined) {
            return res.status(400).send({
                message: 'Validation error',
                errors: validationErrors
            })
        }

        next()
    }
}

