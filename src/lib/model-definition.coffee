
LoopbackUserRepository = require './loopback-user-repository'

###*
loopback model definition of one entity

@class ModelDefinition
@module base-domain-loopback
###
class ModelDefinition

    constructor: (@EntityModel, @LoopbackRepository, @facade) ->

        @definition =
            aclType     : @LoopbackRepository.aclType
            name        : @getName()
            plural      : @getPluralName()
            base        : @getBase()
            idInjection : true
            properties  : {}
            validations : []
            relations   : @getBelongsToRelations()


    ###*
    get model name

    @method getName
    @public
    @return {String} modelName
    ###
    getName: ->
        @EntityModel.getName()


    ###*
    get plural model name: the same as getName() for simplicity

    @method getPluralName
    @private
    @return {String} modelName
    ###
    getPluralName: ->
        return @EntityModel.getName()


    ###*
    get "base" setting.
    "User" or "PersistedModel"

    @method getName
    @public
    @return {String} modelName
    ###
    getBase: ->
        if (@LoopbackRepository::) instanceof LoopbackUserRepository
            return 'User'
        else
            return 'PersistedModel'


    ###*
    Returns the definition

    @method export
    @public
    @return {Object} definition
    ###
    export: ->
        @definition


    ###*
    get props info of sub-entities

    @method getEntityProps
    @return {Object(TypeInfo)}
    ###
    getEntityProps: ->
        info = {}
        modelProps = @facade.getModelProps(@EntityModel.getName())

        for prop in modelProps.entities
            info[prop] = modelProps.dic[prop]

        return info


    ###*
    get "belongsTo" relations

    @private
    ###
    getBelongsToRelations: ->
        rels = {}
        for prop, typeInfo of @getEntityProps()

            rels[prop] =
                type       : 'belongsTo'
                model      : typeInfo.model
                foreignKey : typeInfo.idPropName

        return rels


    ###*
    set "hasMany" relations

    @method setHasManyRelation
    @param {String} relModel
    @param {String} idPropName foreignKey
    ###
    setHasManyRelation: (relModel, idPropName) ->
        rel =
            type       : 'hasMany'
            model      : relModel
            foreignKey : idPropName

        @definition.relations[relModel] = rel


module.exports = ModelDefinition
