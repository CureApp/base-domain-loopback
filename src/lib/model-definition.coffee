
LoopbackRepository = require './loopback-repository'
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
    @return {String} lbModelName
    ###
    getName: ->
        @LoopbackRepository.getLbModelName()


    ###*
    get plural model name: the same as getName() for simplicity

    @method getPluralName
    @private
    @return {String} lbModelName
    ###
    getPluralName: ->
        @LoopbackRepository.getLbModelName()


    ###*
    get "base" setting.
    "User" or "PersistedModel"

    @method getName
    @public
    @return {String}
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

            relModelProps = @facade.getModelProps(typeInfo.model)

            Repo = @facade.require(typeInfo.model + '-repository')
            continue if (Repo::) not instanceof LoopbackRepository

            relLbModelName = Repo.getLbModelName()

            rels[prop] =
                type       : 'belongsTo'
                model      : relLbModelName
                foreignKey : typeInfo.idPropName

        return rels


    ###*
    set "hasMany" relations

    @method setHasManyRelation
    @param {String} relLbModelName
    @param {String} idPropName foreignKey
    ###
    setHasManyRelation: (relLbModelName, idPropName) ->
        rel =
            type       : 'hasMany'
            model      : relLbModelName
            foreignKey : idPropName

        @definition.relations[relLbModelName] = rel


module.exports = ModelDefinition
