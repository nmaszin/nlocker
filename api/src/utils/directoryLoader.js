import fs from 'fs'
import path from 'path'

export async function loadDirectoryModules(pathToDirectory, blacklist) {
    const files = fs.readdirSync(pathToDirectory)
        .filter(filename => !blacklist.includes(filename))
        .map(filename => import(
            './' + path.relative(__dirname, path.join(pathToDirectory, filename))
        ))

    const modules = await Promise.all(files)
    return modules.map(module => module.default)
}
