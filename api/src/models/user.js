import bcrypt from 'bcrypt'
import { createModel } from '@/models'

export default createModel({
    name: 'User',

    fields: {
        email: 'email',
        password: 'password'
    },

    rows: [],

    async initialize(db) {
        await db.query(`
            CREATE TABLE User(
                id INT PRIMARY KEY AUTO_INCREMENT,
                email VARCHAR(100) NOT NULL,
                password VARCHAR(60) NOT NULL,
                UNIQUE(email)
            );
        `)
    },

    async deinitialize(db) {
        await db.query(`DROP TABLE User`)
    },

    select: {
        async selectByEmail(db, email) {
            return db.query(`
                SELECT * FROM User
                WHERE email = ?
            `, [email])
        }
    },

    insert: {
        // Override
        async insert(db, user) {
            const { email, password } = user
            const salt = await bcrypt.genSalt()
            const hash = await bcrypt.hash(password, salt)

            return db.query(`
                INSERT INTO User(email, password)
                VALUES(?, ?)
            `, [email, hash])
        }
    },

    custom: {
        async verify(db, email, password) {
            const [[user], _] = await db.query(`
                SELECT * FROM User
                WHERE email = ?
            `, [email])

            if (user == null) {
                return undefined;
            }

            const hash = user.password
            const ok = await bcrypt.compare(password, hash)
            return ok ? user : undefined;
        }
    }
})
