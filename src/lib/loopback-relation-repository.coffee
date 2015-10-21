
LoopbackRepository = require './loopback-repository'
###*
@class LoopbackUserRepository
@extends LoopbackRepository
@module base-domain-loopback
###
class LoopbackRelationRepository extends LoopbackRepository

    ###*
    prop name this model belongs to

    @property belongsTo
    @protected
    @type String
    ###
    @belongsTo: null


    ###*
    constructor

    @constructor
    @param {Object} [options]
    @param {any} [options.id] the id of the "belongsTo" model
    @param {String}  [options.sessionId] Session ID
    @param {Boolean} [options.debug] shows debug log if true
    ###
    constructor: (options = {}, root) ->
        if not @constructor.belongsTo
            throw new Error """
                You must set @belongsTo and @foreignKeyName when extending RelationRepository.
            """

        super(options, root)

        modelProps = @getModelClass().getModelProps()
        belongsTo = @constructor.belongsTo
        parentPropType = modelProps.getTypeInfo(belongsTo)

        if not modelProps.isEntity belongsTo
            throw new Error """
                "belongsTo" property: #{belongsTo} is not a entity prop.
            """

        @foreignKeyName = parentPropType.idPropName

        relClientOptions =
            one         : parentPropType.model
            many        : @constructor.modelName
            id          : null
            accessToken : @client.accessToken
            timeout     : @client.timeout
            debug       : @client.debug

        @relClient = @getFacade().lbPromised.createRelatedClient(relClientOptions)


    ###*
    get client by entity
    if entity has foreign key, relClient is returned.

    @method getClientByEntity
    @protected
    @param {Entity|Object} entity
    @return {LoopbackClient} client
    ###
    getClientByEntity: (entity) ->
        foreignKey = entity?[@foreignKeyName]
        @getClientByForeignKey(foreignKey)


    ###*
    get client by foreignKey

    @method getClientByForeignKey
    @protected
    @param {String} foreignKey
    @return {LoopbackClient} client
    ###
    getClientByForeignKey: (foreignKey) ->
        if foreignKey?
            @relClient.setId foreignKey
            return @relClient
        else
            return @client


    ###*
    get client by query

    @method getClientByQuery
    @protected
    @param {Object} query
    @return {LoopbackClient} client
    ###
    getClientByQuery: (query) ->
        foreignKey = query?.where?[@foreignKeyName]
        if typeof foreignKey isnt 'object'
            @getClientByForeignKey(foreignKey)
        else
            @client



module.exports = LoopbackRelationRepository
