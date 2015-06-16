
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
        # PushManagerオブジェクト 代わりに @createPushManager() を使用してください
        #
        # @property pushManager
        # @deprecated 
        # @type {PushManager}
        ###
        Object.defineProperty @, 'pushManager', get: -> @createPushManager()


    ###*
    事前にテーブルを読み込む
    ###
    loadMasterTables: ->
        super(
            'symptom'
            'built-in-behavior-therapy'
            'compensation-tool'
        )

    ###*
    service class を取得

    @method getService
    @return {Function}
    ###
    getService: (name) ->

        @require("#{name}-service")


    ###*
    serviceインスタンスを取得

    @method createService
    @return {Base} serviceインスタンス
    ###
    createService: (name) ->
        @create("#{name}-service")


    ###*
    バリデータクラスのオブジェクトを取得する

    @method createValidator
    @param {String} name
    @return {Validator}
    ###
    createValidator: (name)->
        @create("#{name}-validator")


    ###*
    PushManagerオブジェクトを取得する

    @method createPushManager
    @return {PushManager}
    ###
    createPushManager: ->
        # push通知マネージャ
        PushManager = require("#{@constructor.dirname}/util/push-manager")
        @pushManager = new PushManager(@)


    ###*
    ValidationErrorかどうか判定する. duck typing的

    @method isValidationError
    @param {Error} e
    @return {Boolean}
    ###
    isValidationError: (e)->
        return false if not @isDomainError(e)

        return e.reason is 'validationError' and Array.isArray(e.brokenRules) and e.results?



    ###*
    sessionIdをセットする。セットされたあとのcreateRepository()で生成されたリポジトリは、
    そのsessionIdを使うようになる。

    @method setSessionId
    @param {String} sessionId
    ###
    setSessionId: (@sessionId) ->



    ###*
    baseURLをセットする。セットされたあとのcreateRepository()で生成されたリポジトリは、
    そのbaseURLを使うようになる。

    @method setBaseURL
    @param {String} baseURL
    ###
    setBaseURL: (baseURL) ->
        @lbPromised.baseURL = baseURL
        return


# util
Facade.DateUtil        = require './util/date'
Facade.StringGenerator = require './util/string-generator'
Facade.Prefecture      = require './util/prefecture'

# extended domain parts
Facade.Factory            = require './factory'
Facade.Repository         = require './repository'
Facade.UserRepository     = require './user-repository'
Facade.RelationRepository = require './relation-repository'
Facade.Validator          = require './validator'


module.exports = LoopbackDomainFacade
