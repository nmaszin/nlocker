import toposort from 'toposort'
import { createModel } from '@/models'
import { loadDirectoryModules } from '@/utils/directoryLoader'

const getModels = async () => loadDirectoryModules(__dirname, ['index.js', 'db.js'])

function sortModelsByDependencies(models) {
    const modelByName = Object.fromEntries(models.map(model => [model.name, model]))
    const dependencyGraph = models.map(
        model => model.depends.map(dependency => [model.name, dependency])
    ).flat()

    const order = toposort(dependencyGraph)
    for (const name of Object.keys(modelByName)) {
        if (!order.includes(name)) {
            order.push(name)
        }
    }

    return order.map(name => modelByName[name])
}

export default createModel({
    name: 'Db',

    async initialize() {
        const models = sortModelsByDependencies(await getModels())
            .reverse()

        for (const model of models) {
            try {
                await model.initialize()
            } catch (err) {
                console.log(err)
            }
        }
    },

    async deinitialize() {
        const models = sortModelsByDependencies(await getModels())

        for (const model of models) {
            try {
                await model.deinitialize()
            } catch (err) {
                console.log(err)
            }
        }
    }
})
