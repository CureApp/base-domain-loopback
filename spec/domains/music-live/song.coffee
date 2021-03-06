###
generated by base-domain generator
###

Entity = require('base-domain').Entity

###*
entity class of song

@class Song
@extends Entity
###
class Song extends Entity

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
        name      : @TYPES.STRING
        author    : @TYPES.MODEL 'player', 'authorId'
    ### examples
        age         : @TYPES.NUMBER
        confirmed   : @TYPES.BOOLEAN
        confirmedAt : @TYPES.DATE
        team        : @TYPES.MODEL 'team'
        extraTeam   : @TYPES.MODEL 'team', 'exTeamId'
        otherInfo   : @TYPES.OBJECT
        createdAt   : @TYPES.CREATED_AT
        updatedAt   : @TYPES.UPDATED_AT
        temporary   : @TYPES.TMP # temporary prop, removed in toPlainObject()
        tmpObj      : @TYPES.TMP 'OBJECT'
    ###

module.exports = Song
