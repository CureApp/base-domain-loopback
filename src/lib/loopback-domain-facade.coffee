
LoopBackPromised = require 'loopback-promised'

###*
@class LoopbackDomainFacade
@extends Facade
###
class LoopbackDomainFacade extends require('base-domain')

    ###*
    constructor

    @param {Object} [options]
    @param {String} options.baseURL loopback api root
    @param {String} options.sessionId
    @param {Boolean} options.debug
    ###
    constructor: (options = {}) ->

        super(options)

        @moment = require 'moment'

        @debug  = !!options.debug

        @lbPromised = LoopBackPromised.createInstance
            baseURL: options.baseURL

        @sessionId = options.sessionId

        @logger =
            if Ti?
                info  : (v) -> Ti.API.info(v)
                warn  : (v) -> Ti.API.info(v)
                error : (v) -> Ti.API.info(v)
                trace : (v) -> Ti.API.trace(v)
            else if self?
                info  : (v) -> console.log('[INFO]',  v)
                warn  : (v) -> console.log('[WARN]',  v)
                error : (v) -> console.log('[ERROR]', v)
                trace : (v) -> console.log('[TRACE]', v)
            else if console?
                console
            else
                throw new Error "no default logger detected"


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


LoopbackDomainFacade.Repository         = require './loopback-repository'
LoopbackDomainFacade.UserRepository     = require './loopback-user-repository'
LoopbackDomainFacade.RelationRepository = require './loopback-relation-repository'


module.exports = LoopbackDomainFacade
