LoopbackRepository = require('../../base-domain-loopback').LoopbackRepository

###*
a repository for medicine

@class MedicineRepository
@extends LoopbackRepository
###
class MedicineRepository extends LoopbackRepository
    ###*
    model name to create

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: 'medicine'

module.exports = MedicineRepository
