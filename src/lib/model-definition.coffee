
LoopbackUserRepository = require './loopback-user-repository'

###*

@class ModelDefinition
@module base-domain-loopback
###
class ModelDefinition

    constructor: (@EntityModel, @LoopbackRepository) ->

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


    export: ->
        @definition


    ###*
    get property info of sub-entities

    @method getEntityPropInfo
    ###
    getEntityPropInfo: ->
        info = {}
        propInfo = @EntityModel.getPropInfo()

        for prop in @EntityModel.getEntityProps()
            info[prop] = propInfo.dic[prop]

        return info


    ###*
    get "belongsTo" relations

    @private
    ###
    getBelongsToRelations: ->
        rels = {}
        for prop, typeInfo of @getEntityPropInfo()

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
