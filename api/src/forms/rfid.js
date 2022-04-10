import { createForm } from '@/forms'

export default createForm({
    constraints: {
        name: {
            chain: [
                { presence: true },
                { type: 'string' },
                { length: { minimum: 1 } },
            ],
        }
    },
})
