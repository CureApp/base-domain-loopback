###
generated by base-domain generator
###

BaseDomainLoopback = require('../../base-domain-loopback')
###*
repository of player

@class PlayerRepository
@extends LoopbackUserRepository
###
class PlayerRepository extends BaseDomainLoopback.LoopbackUserRepository

    @aclType: 'owner'

    ###*
    model name to create

    @property modelName
    @static
    @protected
    @type String
    ###
    @modelName: 'player'

module.exports = PlayerRepository