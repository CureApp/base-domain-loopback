
debug = require('debug')('base-domain-loopback:setting-exporter')

fs = require 'fs'
LoopbackRepository = require './loopback-repository'
ModelDefinition    = require './model-definition'

###*
export model info into loopback-with-admin's format
only available in Node.js

@class SettingExporter
@module base-domain-loopback
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
            try
                EntityRepository = @facade.getRepository(modelName)
                continue if (EntityRepository::) not instanceof LoopbackRepository
            catch e
                debug('Error in reading repository of %s', modelName)
                debug(e.message)
                debug(e.stack)
                continue

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

        return if not fs.existsSync @facade.dirname

        domainFiles = fs.readdirSync @facade.dirname

        for filename in domainFiles
            try
                [ name, ext ] = filename.split '.'
                @facade.require name
            catch e
                debug('Error in reading file: %s', filename)
                debug(e.message)
                debug(e.stack)


module.exports = SettingExporter
