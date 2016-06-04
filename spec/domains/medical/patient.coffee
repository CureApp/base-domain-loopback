Entity = require('base-domain').Entity
Hospital = require('./hospital')

###*
entity class for patient

@class Patient
@extends Entity
###
class Patient extends Entity

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
        hospital: @TYPES.MODEL 'hospital',
            isOutOfAggregate: true

module.exports = Patient
