'use strict'

LoopbackPromised = require 'loopback-promised'
Facade = require 'base-domain'

###*
@class LoopbackDomainFacade
@extends Facade
@module base-domain-loopback
###
class LoopbackDomainFacade extends Facade

    ###*
    constructor

    @param {Object} [options]
    @param {String} options.baseURL loopback api root
    @param {String} options.sessionId
    @param {Boolean} options.debug
    ###
    constructor: (options = {}) ->

        super(options)

        @debug  = !!options.debug

        @lbPromised = LoopbackPromised.createInstance
            baseURL: options.baseURL

        @sessionId = options.sessionId

        @timeout = options.timeout


    ###*
    set sessionId. Repositories generated after setSessionId(newSessionIDs) use the new sessionId

    @method setSessionId
    @param {String} sessionId
    ###
    setSessionId: (@sessionId) ->



    ###*
    set baseURL. Repositories generated after setBaseURL(newBaseURL) use the new baseURL

    @method setBaseURL
    @param {String} baseURL
    ###
    setBaseURL: (baseURL) ->
        @lbPromised.baseURL = baseURL
        return


    ###*
    Get model definition objects, which [loopback-with-admin](https://github.com/CureApp/loopback-with-admin))))

    @method getModelDefinitions
    @return {Object}
    ###
    getModelDefinitions: ->
        new @constructor.SettingExporter(@).export()


    @LoopbackRepository         : require './loopback-repository'
    @LoopbackUserRepository     : require './loopback-user-repository'
    @LoopbackRelationRepository : require './loopback-relation-repository'


module.exports = LoopbackDomainFacade
