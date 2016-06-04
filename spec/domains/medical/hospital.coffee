Entity = require('base-domain').Entity

###*
entity class for hospital

@class Hospital
@extends Entity
###
class Hospital extends Entity

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

module.exports = Hospital
