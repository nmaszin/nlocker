import { createModel } from '@/models'

export default createModel({
    name: 'Locker',

    fields: {
        name: 'name',
        ownerId: 'owner_id',
        creationTime: 'creation_time'
    },

    depends: [
        'User'
    ],

    async initialize(db) {
        await db.query(`
            CREATE TABLE Locker(
                id INT PRIMARY KEY AUTO_INCREMENT,
                name VARCHAR(60) NOT NULL,
                owner_id INT NOT NULL,
                creation_time DATETIME NOT NULL,
                FOREIGN KEY(owner_id) REFERENCES User(id)
            );
        `)
    },

    async deinitialize(db) {
        await db.query(`DROP TABLE Locker`)
    },

    select: {
        many: {
            async selectByOwner(db, userId) {
                return db.query(`
                    SELECT * FROM Locker
                    WHERE owner_id = ?
                `, [userId])
            }
        }
    },

    /*select: {
        single: {
            async selectByIdAndOwner(db, id, ownerId) {
                return db.query(`SELECT * FROM Locker WHERE id = ? AND owner_id = ?`, [id, ownerId])
            }
        },
        many: {
            async selectAllByOwner(db, ownerId) {
                return db.query(`SELECT * FROM Locker WHERE owner_id = ?`, [ownerId])
            },
        }
    },

    update: {
        async updateByOwner(db, id, locker, userId) {
            const { name, description, ownerId } = locker
            db.query(`
                UPDATE Locker
                SET name = ?, description = ?, owner_id = ?
                WHERE id = ? AND owner_id = ?
            `, [name, description, ownerId, id, userId])
        }
    },

    delete: {
        async deleteByOwner(db, id, userId) {
            db.query(`
                DELETE FROM Locker
                WHERE id = ? AND owner_id = ?
            `, [id, userId])
        }
    }*/
})
