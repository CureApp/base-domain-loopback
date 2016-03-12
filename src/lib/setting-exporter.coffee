'use strict'

debug = require('debug')('base-domain-loopback:setting-exporter')

fs = require 'fs'
LoopbackRepository = require './loopback-repository'
ModelDefinition    = require './model-definition'

###*
export model info into loopback-with-admin's format (loopback-with-admin >=v1.8.0)
only available in Node.js

@class SettingExporter
@module base-domain-loopback
###
class SettingExporter

    constructor: (@facade) ->


    ###*
    Create loopback definition setting object
    @method export
    @public
    @return {Object}
    ###
    export: ->
        models: @createModelDefinitions()
        customRoles: @createCustomRoleDefinitions()


    ###*
    Create definitions of custom roles (for ACL).

    Prepare directory containing js files exporting a function to pass to Role.registerResolver(name, fn)
    https://docs.strongloop.com/display/public/LB/Defining+and+using+roles
    http://apidocs.strongloop.com/loopback/#role-registerresolver

    Define the directory as Facade#customRolePath or move the directory to Facade#dirname + '/custom-roles'

    The name of each custom role is the filename without extension.
    e.g. team-member.js : team-member

    @method createCustomRoleDefinitions
    @return {Object}
    ###
    createCustomRoleDefinitions: ->

        customRolePath = @facade.customRolePath ? @facade.dirname + '/custom-roles'

        if not fs.existsSync(customRolePath) or not fs.statSync(customRolePath).isDirectory()
            return null

        customRoles = {}

        for filename in fs.readdirSync(customRolePath) when filename.slice(-3) is '.js'
            roleName = filename.slice(0, -3)
            customRoles[roleName] = customRolePath + '/' + filename

        return customRoles



    ###*
    Create ModelDefinitions

    1. load all the entities
    2. check each entity's repository is LoopbackRepository
    3. create ModelDefinition
    4. add "hasMany" relations
    5. add "hasManyThrough" relations
    6. add custom relations
    7. return object

    @method createModelDefinitions
    @private
    @return {Object}
    ###
    createModelDefinitions: ->

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
