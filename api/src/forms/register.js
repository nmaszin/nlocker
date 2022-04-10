import { createForm } from '@/forms'

export default createForm({
    constraints: {
        email: {
            chain: [
                { presence: true },
                { type: 'string' },
                { email: true }
            ],
        },
        password: {
            chain: [
                { presence: true },
                { type: 'string' },
                { length: { minimum: 8 } },
            ],
        },
        confirmPassword: {
            presence: true,
            type: 'string',
            length: { min: 8 },
            equality: 'password'
        }
    },
})
