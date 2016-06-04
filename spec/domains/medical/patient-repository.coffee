LoopbackRepository = require('../../base-domain-loopback').LoopbackRepository

###*
a repository for patient

@class PatientRepository
@extends LoopbackRepository
###
class PatientRepository extends LoopbackRepository
    ###*
    model name to create

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: 'patient'

module.exports = PatientRepository
