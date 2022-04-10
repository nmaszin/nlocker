import validatejs from 'validate.js'

validatejs.validators.validIdentifier = value => {
    const requirement = Number.isInteger(value) && value >= 1
    if (!requirement) {
        return "is not valid identifier"
    }
}

validatejs.validators.foreignKey = async (id, model) => {
    const record = await model.selectById(id)
    if (record === undefined) {
        return "refers to non existing record"
    }
}

// Process validators in given order
// If particular validator returns any errors, the chain won't call the rest of validators
validatejs.validators.chain = async (value, rules, attribute) => {
    for (const rule of rules) {
        const data = { [attribute]: value }
        const constraints = { [attribute]: rule }

        const errors = await validator(data, constraints, { fullMessages: false })
        if (errors !== undefined) {
            return errors[attribute]
        }
    }
}

// Validators default messages override
validatejs.validators.presence.message = 'is required'

async function validator(data, constraints, options) {
    const errors = await new Promise(resolve =>
        validatejs.async(data, constraints, options)
            .then(() => resolve())
            .catch(errors => resolve(errors))
    )

    const redundantFieldsErrors = {}
    for (const attribute of Object.keys(data)) {
        if (constraints[attribute] === undefined) {
            redundantFieldsErrors[attribute] = ['Redundant attribute']
        }
    }

    if (errors !== undefined) {
        return { ...errors, ...redundantFieldsErrors }
    } else if (Object.keys(redundantFieldsErrors).length > 0) {
        return redundantFieldsErrors
    } else {
        return undefined
    }
}

export default validator
