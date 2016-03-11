'use strict'

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
    Create ModelDefinitions

    1. load all the entities
    2. check each entity's repository is LoopbackRepository
    3. create ModelDefinition
    4. add "hasMany" relations
    5. add "hasManyThrough" relations
    6. add custom relations
    7. return object

    @method export
    @public
    @return {Object}
    ###
    export: ->

        definitions = {}

        for EntityModel in @getAllEntityModels()
            modelName = EntityModel.getName()
            try
                EntityRepository = @facade.require(modelName + '-repository')
                if (EntityRepository::) not instanceof LoopbackRepository
                    debug('%s is not instance of LoopbackRepository', modelName + '-repository')
                    continue
            catch e
                if e.message.match /model .*? is not found/
                    debug('%s does not have Repository', modelName)
                else
                    debug('Error in reading repository of %s', modelName)
                    debug(e.message)
                    debug(e.stack)
                continue

            lbModelName = EntityRepository.getLbModelName()

            debug('model "%s" is added to model definition (loopback name: "%s")', modelName, lbModelName)

            definitions[lbModelName] = new ModelDefinition(EntityModel, EntityRepository, @facade)

        @setHasManyRelations(definitions)
        @setHasManyThroughRelation(definitions)

        for name, definition of definitions
            definition.addCustomRelations()
            definitions[name] = definition.export()

        debug('models for loopback: %s', Object.keys(definitions).join(', '))

        return definitions


    ###*
    set "hasMany" relations

    @private
    ###
    setHasManyRelations: (definitions) ->

        for lbModelName, definition of definitions
            for prop, typeInfo of definition.getEntityProps()
                relLbModelName = @getLbModelName(typeInfo.model)
                continue if not relLbModelName
                relModelDefinition = definitions[relLbModelName]
                relModelDefinition?.setHasManyRelation(lbModelName, typeInfo.idPropName)


    ###*
    set "hasManyThrough" relations

    @private
    ###
    setHasManyThroughRelation: (definitions) ->

        for lbModelName, definition of definitions
            lbEntityProps = {}
            for prop, typeInfo of definition.getEntityProps()

                if @getLbModelName(typeInfo.model)
                    lbEntityProps[prop] = typeInfo

            props = Object.keys(lbEntityProps)

            for propA, i in props
                propB = props[i + 1]
                break if not propB?

                typeInfoA = lbEntityProps[propA]
                typeInfoB = lbEntityProps[propB]

                modelA = @getLbModelName(typeInfoA.model)
                modelB = @getLbModelName(typeInfoB.model)

                defA = definitions[modelA]
                defB = definitions[modelB]

                defA.setHasManyThroughRelation
                    model: modelB
                    foreignKey: typeInfoA.idPropName
                    keyThrough: typeInfoB.idPropName
                    through: lbModelName

                defB.setHasManyThroughRelation
                    model: modelA
                    foreignKey: typeInfoB.idPropName
                    keyThrough: typeInfoA.idPropName
                    through: lbModelName


    getLbModelName: (modelName) ->
        try
            Repo = @facade.require(modelName + '-repository')
            return null if (Repo::) not instanceof LoopbackRepository
            return Repo.getLbModelName()
        catch e
            return null


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
                continue if ext not in ['coffee', 'js']
                @facade.require name
            catch e
                debug('Error in reading file: %s', filename)
                debug(e.message)
                debug(e.stack)


module.exports = SettingExporter
