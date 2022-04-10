import { catchAllExceptions } from '@/middlewares/errors'

export function controller(controller) {
    return catchAllExceptions(controller)
}

