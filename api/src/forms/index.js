import validator from '@/services/validator'

export function createForm(object) {
    return {
        validate: async data => validator(data, object.constraints)
    }
}
