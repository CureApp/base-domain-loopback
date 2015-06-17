
BaseDomainLoopback = require('../../base-domain-loopback')


###*
repository of instrument

@class InstrumentRepository
@extends LoopbackRepository
###
class InstrumentRepository extends BaseDomainLoopback.LoopbackRepository

    ###*
    model name to create

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: 'instrument'

module.exports = InstrumentRepository
