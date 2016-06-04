

SettingExporter = require '../../src/lib/setting-exporter'
Facade = require '../base-domain-loopback'

describe 'SettingExporter', ->

    beforeEach ->

        @domain = require('../create-facade').create(dirname: __dirname + '/../domains/music-live')
        @loopbackDefinitions = new SettingExporter(@domain).export()
        @modelDefinitions = @loopbackDefinitions.models


    describe 'export', ->

        it 'export entities', ->
            assert typeof @modelDefinitions.song is 'object'
            assert typeof @modelDefinitions.player is 'object'
            assert typeof @modelDefinitions.instrument is 'object'

        it 'does not export entity with no repository', ->
            assert not @modelDefinitions.staff?

        it 'does not export non entity models', ->
            assert not @modelDefinitions['live-info']?


        it 'appends "hasMany" relations', ->
            playerDefObj = @modelDefinitions.player
            assert playerDefObj.relations?
            assert playerDefObj.relations.song?
            assert playerDefObj.relations.song.type is 'hasMany'

        it 'does not append "hasMany" relations to non-has-many relations', ->
            console.log @modelDefinitions
            for entityName in ['instrument', 'song']
                rels = @modelDefinitions[entityName].relations
                for relProp, relInfo of rels
                    assert.notEqual relInfo.type, 'hasMany'
                    assert relInfo.type is 'belongsTo'

        context 'medical', ->
            beforeEach ->
                @domain = require('../create-facade').create(dirname: __dirname + '/../domains/medical')
                @loopbackDefinitions = new SettingExporter(@domain).export()
                @modelDefinitions = @loopbackDefinitions.models

            it.only 'does not append "hasMany" relations to a model that is out of aggregate', ->
                assert Object.keys(@modelDefinitions.hospital.relations).length is 0



    describe 'getAllEntityModels', ->

        it 'returns all entity models registered in the domain', ->
            classes = new SettingExporter(@domain).getAllEntityModels()

            assert classes.length is 4

            for klass in classes
                assert(klass::) instanceof Facade.Entity
                assert klass.isEntity


    describe 'loadAll', ->

        it 'does nothing when there is no domain dir', ->

            d = require('../create-facade').create(dirname: __dirname + '/../domains/xxx-no-dir')

            assert not require('fs').existsSync(d.dirname)

            assert Object.keys d.classes.length is 0

            new SettingExporter(d).loadAll()

            assert Object.keys d.classes.length is 0



        it 'requires entity models in the domain dir', ->
            d = require('../create-facade').create(dirname: __dirname + '/../domains/music-live')
            assert Object.keys d.classes.length is 0
            new SettingExporter(d).loadAll()
            assert Object.keys d.classes.length is 13


module.exports = SettingExporter
