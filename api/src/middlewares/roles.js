export function checkRole(whitelist) {
    return (req, res, next) => {
        const user = req.user.data
        if (!whitelist.includes(user.role)){
            return res.status(403).send({
                message: 'Forbidden'
            })
        }

        next();
    }
}

export function atLeastReader(req, res, next) {
    return checkRole([0, 1, 2])(req, res, next)
}

export function atLeastWriter(req, res, next) {
    return checkRole([1, 2])(req, res, next)
}

export function atLeastAdmin(req, res, next) {
    return checkRole([2])(req, res, next)
}

