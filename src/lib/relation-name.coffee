'use strict'

module.exports = (params = {}) ->

    { model, foreignKey, keyThrough, through } = params

    if through
        return model + '-via-' + keyThrough + '-at-' + through + '-with-' + foreignKey

    else if foreignKey
        return model + '-with-' + foreignKey

    else
        return model

