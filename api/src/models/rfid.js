import { createModel } from '@/models'

export default createModel({
    name: 'Rfid',

    fields: {
        name: 'name',
        value: 'value',
        lockerId: 'locker_id',
        creationTime: 'creation_time'
    },

    depends: [
        'Locker'
    ],

    async initialize(db) {
        await db.query(`
            CREATE TABLE Rfid(
                id INT PRIMARY KEY AUTO_INCREMENT,
                name VARCHAR(60) NOT NULL,
                value VARCHAR(100) NOT NULL,
                locker_id INT NOT NULL,
                creation_time DATETIME NOT NULL,
                FOREIGN KEY(locker_id) REFERENCES Locker(id)
            );
        `)
    },

    async deinitialize(db) {
        await db.query(`DROP TABLE Rfid`)
    },

    select: {
        many: {
            async selectByLocker(db, lockerId) {
                return db.query(`
                    SELECT * FROM Rfid
                    WHERE locker_id = ?
                `, [lockerId])
            }
        }
    }
})
