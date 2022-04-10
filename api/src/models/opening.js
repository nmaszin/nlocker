import { createModel } from '@/models'

export default createModel({
    name: 'Opening',

    fields: {
        time: 'time',
        lockerId: 'locker_id',
        rfidId: 'rfid_id',
        name: 'name'
    },

    depends: [
        'Locker',
        'Rfid'
    ],

    async initialize(db) {
        await db.query(`
            CREATE TABLE Opening(
                id INT PRIMARY KEY AUTO_INCREMENT,
                time DATETIME NOT NULL,
                locker_id INT NOT NULL,
                rfid_id INT,
                FOREIGN KEY(locker_id) REFERENCES Locker(id),
                FOREIGN KEY(rfid_id) REFERENCES Rfid(id)
            );
        `)
    },

    async deinitialize(db) {
        await db.query(`DROP TABLE Opening`)
    },

    select: {
        many: {
            async selectByLocker(db, lockerId) {
                return db.query(`
                    SELECT Opening.id, Opening.time, Opening.locker_id, Opening.rfid_id, Rfid.name
                    FROM Opening
                    LEFT OUTER JOIN Rfid
                    ON Rfid.id = Opening.rfid_id
                    WHERE Opening.locker_id = ?
                `, [lockerId])
            }
        }
    },
    insert: {
        async insert(db, data) {
            return db.query(`
                INSERT INTO Opening(time, locker_id, rfid_id)
                VALUES(?, ?, ?)
            `, [data.time, data.lockerId, data.rfidId])
        }
    }
})
