###
generated by base-domain generator
###


BaseFactory = require('base-domain').BaseFactory


###*
factory of instrument

@class InstrumentFactory
@extends BaseFactory
###
class InstrumentFactory extends BaseFactory

    ###*
    model name to create

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: 'instrument'

module.exports = InstrumentFactory
