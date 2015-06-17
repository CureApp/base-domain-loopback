
fs = require 'fs'
LoopbackRepository = require './loopback-repository'
ModelDefinition    = require './model-definition'

###*
@class SettingExporter
###
class SettingExporter

    constructor: (@facade) ->

    ###*
    create ModelDefinitions

    @private
    ###
    export: ->

        definitions = {}

        for EntityModel in @getAllEntityModels()
            modelName = EntityModel.getName()
            EntityRepository = @facade.getRepository(modelName)

            continue if (EntityRepository::) not instanceof LoopbackRepository

            definitions[modelName] = new ModelDefinition(EntityModel, EntityRepository)

        @setHasManyRelations(definitions)

        definitions[name] = definition.export() for name, definition of definitions

        return definitions


    ###*
    set "hasMany" relations

    @private
    ###
    setHasManyRelations: (definitions) ->

        for modelName, definition of definitions
            for prop, typeInfo of definition.getEntityPropInfo()
                relModelName = typeInfo.model
                relModelDefinition = definitions[relModelName]
                relModelDefinition?.setHasManyRelation(modelName, typeInfo.idPropName)


    ###*
    get all entity models registered in domain facade

    @private
    ###
    getAllEntityModels: ->

        @loadAll()
        return (klass for name, klass of @facade.classes when klass.isEntity)


    ###*
    load all models in directory

    @private
    ###
    loadAll: ->

        domainFiles = fs.readdirSync @facade.dirname

        for filename in domainFiles
            try
                [ name, ext ] = filename.split '.'
                @facade.require name
            catch e
                console.log e
                console.log e.stack


module.exports = SettingExporter
