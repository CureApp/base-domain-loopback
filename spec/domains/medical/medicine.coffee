Entity = require('base-domain').Entity

###*
entity class for medicine

@class Medicine
@extends Entity
###
class Medicine extends Entity

    ###*
    property types
    key:   property name
    value: type

    @property properties
    @static
    @protected
    @type Object
    ###
    @properties:
        name: @TYPES.STRING
        patient: @TYPES.MODEL 'patient',
            isOutOfAggregate: true
        hospital: @TYPES.MODEL 'hospital',
            isOutOfAggregate: true

module.exports = Medicine
