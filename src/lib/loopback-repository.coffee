'use strict'

{ BaseAsyncRepository, Entity } = require('base-domain')

moment = require 'moment'
relationName = require './relation-name'

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
    Map to convert loopback's object prop into model prop

    key:   loopback's prop
    value: model prop

    if value is null or undefined, the property only exists in loopback and is removed from the created model.

    @property {Object} props
    @static
    ###
    @props: null


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

        facade = @facade


        lbModelName = @constructor.getLbModelName()

        sessionId = options.sessionId or facade.sessionId

        [accessToken, userId] = @parseSessionId sessionId

        options.accessToken ?= accessToken
        options.debug       ?= facade.debug
        options.timeout     ?= facade.timeout

        @client = facade.lbPromised.createClient(lbModelName, options)

        @relClients = {}


    ###*
    get model name used in LoopBack
    @method getLbModelName
    @static
    @return {String}
    ###
    @getLbModelName: ->
        @lbModelName or @modelName



    ###*
    Create model instance from result from client

    @method createFromResult
    @protected
    @param {Object} obj
    @param {Object} [options]
    @return {BaseModel} model
    ###
    createFromResult: (obj, options) ->

        return super if not obj?

        for lbProp, prop of @constructor.props ? {}
            if prop?
                obj[prop] = obj[lbProp]

            delete obj[lbProp]

        super(obj, options)


    ###*
    convert 'date' type property for loopback format

    @method modifyDate
    @private
    @param {Entity|Object} data
    ###
    modifyDate: (data) ->
        modelProps = @facade.getModelProps(@getModelName())
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
        if not options.client and options.relation
            options.client = @getRelatedClient(options.relation)
        else
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
        if not options.client and options.relation
            options.client = @getRelatedClient(options.relation)
        else
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
    query: (params = {}, options = {}) ->

        if params.relation and not options.relation
            options.relation = params.relation

        if not options.client and options.relation
            options.client = @getRelatedClient(options.relation)
        else
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
        if not options.client and options.relation
            options.client = @getRelatedClient(options.relation)
        else
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
        if not options.client and options.relation
            options.client = @getRelatedClient(options.relation)
        else
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
        if not options.client and options.relation
            options.client = @getRelatedClient(options.relation)
        else
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
    count: (where = {}, options = {}) ->

        if options.client
            { client } = options
        else if options.relation
            client = @getRelatedClient(options.relation)
        else
            client ?= @getClientByQuery(where: where)

        client.count(where)


    ###*
    Get loopback-related-client
    @method getRelatedClient
    @protected
    @param {Object} params
    @param {String} params.modelName foreign model name
    @param {String} params.id foreign id
    @param {String} [params.relation] relation name
    @param {String} [params.foreignKey] foreign key prop.
    @param {String} [params.through]
    @param {String} [params.keyThrough]
    @return {LoopbackRelatedClient}
    ###
    getRelatedClient: (params = {}) ->

        { model, name, id, foreignKey, through, keyThrough } = params

        return null if not model

        relName = name ? relationName
            model      : @constructor.getLbModelName()
            foreignKey : foreignKey
            through    : through
            keyThrough : keyThrough

        clientKey = model + '.' + relName

        if client = @relClients[clientKey]
            client.setId id
            return client

        try
            Repo = @facade.require(model + '-repository')
            throw new Error() if (Repo::) not instanceof LoopbackRepository
        catch e
            console.error("""
                Error in LoopbackRepository#getRelatedClient(). '#{model}-repository' is not found,
                or it is not an instance of LoopbackRepository.
                model name must be compatible with LoopbackRepository when querying with relation.
            """)
            return null


        relClientOptions =
            one         : Repo.getLbModelName()
            many        : relName
            id          : id
            accessToken : @client.accessToken
            timeout     : @client.timeout
            debug       : @client.debug

        @relClients[clientKey] = @facade.lbPromised.createRelatedClient(relClientOptions)



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
