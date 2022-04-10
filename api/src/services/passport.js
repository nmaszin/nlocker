import passport from 'passport'
import passportLocal from 'passport-local'
import passportJwt from 'passport-jwt'
import User from '@/models/user'
import Locker from '@/models/locker'

async function verifyEmailAndPassword(email, password, done) {
    const user = await User.verify(email, password)
    if (user === undefined) {
        return done(null, false)
    }

    return done(null, user)
}

async function verifyAuthToken(payload, done) {
    const { id, type } = payload
    if (type !== 'user') {
        return done('Invalid token type')
    }

    const user = await User.selectById(id)
    if (user === undefined) {
        return done('User does not exist');
    }

    return done(null, user)
}

async function verifyLockerPairingToken(payload, done) {
    const { id, type } = payload
    if (type !== 'pair') {
        return done('Invalid token type')
    }

    const user = await User.selectById(id)
    if (user === undefined) {
        return done('User does not exist')
    }

    return done(null, user)
}

async function verifyLockerToken(payload, done) {
    const { id, type } = payload
    if (type !== 'locker') {
        return done('Invalid token type')
    }

    const locker = await Locker.selectById(id)
    if (locker === undefined) {
        return done('Locker does not exist')
    }

    return done(null, locker)
}

export default () => {
    passport.use(new passportLocal.Strategy({
            usernameField: 'email',
            passwordField: 'password'
        },
        verifyEmailAndPassword
    ))

    passport.use(
        new passportJwt.Strategy({
            jwtFromRequest: passportJwt.ExtractJwt.fromAuthHeaderAsBearerToken(),
            secretOrKey: process.env.JWT_SECRET
        },
        verifyAuthToken
    ))

    passport.use(
        'locker-pairing',
        new passportJwt.Strategy({
            jwtFromRequest: passportJwt.ExtractJwt.fromAuthHeaderAsBearerToken(),
            secretOrKey: process.env.JWT_SECRET
        },
        verifyLockerPairingToken
    ))

    passport.use(
        'locker',
        new passportJwt.Strategy({
            jwtFromRequest: passportJwt.ExtractJwt.fromAuthHeaderAsBearerToken(),
            secretOrKey: process.env.JWT_SECRET
        },
        verifyLockerToken
    ))
}
