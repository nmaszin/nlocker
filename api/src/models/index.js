import lodash from 'lodash'
import database from '@/services/database'

export function genericMapRow(row, mapping) {
    const { id } = row
    const data = Object.fromEntries(
        Object.entries(mapping)
            .map(([modelKey, dbKey]) => [modelKey, row[dbKey]])
            .filter(([_, value]) => value !== undefined)
    )

    return { id, data }
}

export function flattenSelect(row) {
    return {
        id: row.id,
        ...row.data
    }
}

export function injectDb(callback) {
    return async (...params) => {
        const db = await database.connect()
        return callback(db, ...params)
    }
}

const checkIfAlreadyExists = method => {
    if (method !== undefined) {
        throw new Error(`Method ${method} already exists in model`)
    }
}

const defaultImplementation = model => ({
    depends: [],
    rows: [],

    select: {
        single: {
            async selectById(db, id) {
                return db.query(`SELECT * FROM ${model.name} WHERE id = ?`, [id])
            }
        },
        many: {
            async selectAll(db) {
                return db.query(`SELECT * FROM ${model.name}`)
            },
        }
    },

    insert: {
        async insert(db, data) {
            const fieldsValuesMapping = Object.entries(model.fields)
                .map(([attribute, dbField]) => [dbField, data[attribute]])

            const fields = fieldsValuesMapping.map(e => e[0])
            const values = fieldsValuesMapping.map(e => e[1])
            const questionMarks = Array(values.length).fill('?')

            return db.query(`
                INSERT INTO ${model.name}(${fields.join(', ')})
                VALUES(${questionMarks.join(', ')})
            `, values)
        },
    },

    update: {
        async updateById(db, id, data) {
            const fieldsValuesMapping = Object.entries(model.fields)
                .map(([attribute, dbField]) => [dbField, data[attribute]])

            const fields = fieldsValuesMapping.map(e => e[0])
            const values = fieldsValuesMapping.map(e => e[1])

            return db.query(`
                UPDATE ${model.name}
                SET ${fields.map(f => `${f} = ?`).join(', ')}
                WHERE id = ?
            `, [...values, id])
        }
    },

    delete: {
        async deleteById(db, id) {
            return db.query(`DELETE FROM ${model.name} WHERE id = ?`, [id])
        }
    }
})

export function createModel(object) {
    object = lodash.merge(
        defaultImplementation(object),
        object
    )
    
    const model = {
        name: object.name,
        depends: object.depends
    }

    if (object.select !== undefined) {
        if (object.select.single !== undefined) {
            for (const [name, fn] of Object.entries(object.select.single)) {
                checkIfAlreadyExists(model[name])
                model[name] = async (...params) => {
                    const [rows, _] = await injectDb(fn)(...params)
                    return rows.map(row => genericMapRow(row, object.fields))[0]
                }
            }
        }

        if (object.select.many !== undefined) {
            for (const [name, fn] of Object.entries(object.select.many)) {
                checkIfAlreadyExists(model[name])
                model[name] = async (...params) => {
                    const [rows, _] = await injectDb(fn)(...params)
                    return rows.map(row => genericMapRow(row, object.fields))
                }
            }
        }
    }

    if (object.insert !== undefined) {
        for (const [name, fn] of Object.entries(object.insert)) {
            checkIfAlreadyExists(model[name])
            model[name] = async (...params) => {
                try {
                    const [rows, _] = await injectDb(fn)(...params)
                    return rows.insertId
                } catch (e) {
                    console.log(e)
                    return undefined
                }
            }
        }
    }

    [object.update, object.delete].forEach(entry => {
        if (entry !== undefined) {
            for (const [name, fn] of Object.entries(entry)) {
                checkIfAlreadyExists(model[name])
                model[name] = async (...params) => {
                    try {
                        const [fields, _] = await injectDb(fn)(...params)
                        return fields.affectedRows > 0
                    } catch (e) {
                        console.log(e);
                        return 0;
                    }
                }
            }
        }
    })

    if (object.initialize !== undefined) {
        model.initialize = async (...params) => {
            await injectDb(object.initialize)()
            for (const row of object.rows) {
                await model.insert(row)
            }
        }
    }

    if (object.deinitialize !== undefined) {
        model.deinitialize = injectDb(object.deinitialize)
    }

    if (object.custom !== undefined) {
        for (const [name, fn] of Object.entries(object.custom)) {
            checkIfAlreadyExists(model[name])
            model[name] = injectDb(fn)
        }
    }

    return model
}
