LoopbackRepository = require('../../base-domain-loopback').LoopbackRepository

###*
a repository for hospital

@class HospitalRepository
@extends LoopbackRepository
###
class HospitalRepository extends LoopbackRepository
    ###*
    model name to create

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: 'hospital'

module.exports = HospitalRepository
