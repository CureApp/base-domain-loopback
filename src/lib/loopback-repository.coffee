
{ BaseAsyncRepository, Entity } = require('base-domain')

moment = require 'moment'
###*
@class LoopbackRepository
@extends BaseAsyncRepository
@module base-domain-loopback
###
class LoopbackRepository extends BaseAsyncRepository

    ###*
    aclType : type of access control list in [loopback-with-admin](https://github.com/cureapp/loopback-with-admin)
    ###
    @aclType: 'admin'


    ###*
    model name used in Loopback
    it will be the same value as @modelName if not set

    @property lbModelName
    @static
    @type String
    ###
    @lbModelName: ''


    ###*
    constructor

    @constructor
    @param {Object}  [options]
    @param {String}  [options.sessionId] Session ID
    @param {Boolean} [options.debug] shows debug log if true
    @params {RootInterface} root
    ###
    constructor: (options = {}, root) ->
        super(root)

        facade = @getFacade()


        lbModelName = @constructor.getLbModelName()

        sessionId = options.sessionId or facade.sessionId

        [accessToken, userId] = @parseSessionId sessionId

        options.accessToken ?= accessToken
        options.debug       ?= facade.debug
        options.timeout     ?= facade.timeout

        @client = facade.lbPromised.createClient(lbModelName, options)


    ###*
    get model name used in LoopBack
    @method getLbModelName
    @static
    @return {String}
    ###
    @getLbModelName: ->
        @lbModelName or @modelName


    ###*
    convert 'date' type property for loopback format

    @method modifyDate
    @private
    @param {Entity|Object} data
    ###
    modifyDate: (data) ->
        modelProps = @getFacade().getModelProps(@getModelName())
        for dateProp in modelProps.dates
            val = data[dateProp]
            if val?
                data[dateProp] = moment(val).toISOString()
        return


    ###*
    Update or insert a model instance

    @method save
    @public
    @param {Entity|Object} entity
    @param {Object} [options]
    @return {Promise(Entity)} entity (the same instance from input, if entity given,)
    ###
    save: (entity, options = {}) ->
        options.client ?= @getClientByEntity(entity)

        @modifyDate(entity)
        super(entity, options)


    ###*
    get entity by id.

    @method get
    @public
    @param {String|Number} id
    @param {Object} [options]
    @param {String} [options.foreignKey]
    @return {Promise(Entity)} entity
    ###
    get: (id, options = {}) ->
        options.client ?= @getClientByForeignKey(options.foreignKey)
        super(id, options)


    ###*
    get entities by id.

    @method getByIds
    @public
    @param {Array|(String|Number)} ids
    @param {Object} [options]
    @return {Promise(Array(Entity))} entities
    ###
    getByIds: (ids, options) ->
        @query(where: { id: inq: ids }, options)


    ###*
    Find all model instances that match params

    @method query
    @public
    @param {Object} [params] query parameters
    @param {Object} [options]
    @return {Promise(Array(Entity))} array of entities
    ###
    query: (params, options = {}) ->
        options.client ?= @getClientByQuery(params)
        super(params, options)


    ###*
    Find one model instance that matches params, Same as query, but limited to one result

    @method singleQuery
    @public
    @param {Object} [params] query parameters
    @param {Object} [options]
    @return {Promise(Entity)} entity
    ###
    singleQuery: (params, options = {}) ->
        options.client ?= @getClientByQuery(params)
        super(params, options)



    ###*
    Destroy the given entity (which must have "id" value)

    @method delete
    @public
    @param {Entity} entity
    @param {Object} [options]
    @return {Promise(Boolean)} isDeleted
    ###
    delete: (entity, options = {}) ->
        options.client ?= @getClientByEntity(entity)
        super(entity, options)


    ###*
    Update set of attributes.

    @method update
    @public
    @param {any} id id of the entity to update
    @param {Object} data key-value pair to update
    @param {Object} [options]
    @return {Promise(Entity)} updated entity
    ###
    update: (id, data, options = {}) ->
        options.client ?= @getClientByEntity(data) # FIXME fails if data doesnt contain foreign key
        @modifyDate(data)
        super(id, data, options)



    ###*
    Return the number of models that match the optional "where" filter.

    @method count
    @public
    @param {Object} [where]
    @return {Promise(Number)}
    ###
    count: (where = {}) ->

        client = @getClientByQuery(where: where)

        client.count(where)



    ###*
    get client by entity. By default it returns @client

    @method getClientByEntity
    @protected
    @param {Entity|Object} entity
    @return {LoopbackClient} client
    ###
    getClientByEntity: (entity) ->
        return @client


    ###*
    get client by foreign key. By default it returns @client

    @method getClientByForeignKey
    @protected
    @param {String} foreignKey
    @return {LoopbackClient} client
    ###
    getClientByForeignKey: (foreignKey) ->
        return @client


    ###*
    get client by query value. By default it returns @client

    @method getClientByQuery
    @protected
    @param {Object} query
    @return {LoopbackClient} client
    ###
    getClientByQuery: (query) ->
        return @client


    ###*
    get accessToken and userId by sessionId

    @method parseSessionId
    @protected
    @param {String} sessionId
    @return {Array(String)} [accessToken, userId]
    ###
    parseSessionId: (sessionId) ->
        if not sessionId
            return [null, null]
        return sessionId.split('/')



module.exports = LoopbackRepository
