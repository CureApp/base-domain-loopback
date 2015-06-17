

SettingExporter = require '../../src/lib/setting-exporter'

domain = require('../create-facade').create(dirname: __dirname + '/../domains/music-live')

Facade = domain.constructor


describe 'SettingExporter', ->

    before ->

        @result = new SettingExporter(domain).export()

    describe 'export', ->

        it 'export entities', ->
            expect(@result.song).to.be.an 'object'
            expect(@result.player).to.be.an 'object'
            expect(@result.instrument).to.be.an 'object'

        it 'does not export non entity models', ->
            expect(@result['live-info']).not.to.exist


        it 'appends "hasMany" relations', ->
            playerDefObj = @result.player
            expect(playerDefObj).to.have.property 'relations'
            expect(playerDefObj.relations).to.have.property 'song'
            expect(playerDefObj.relations.song).to.have.property 'type', 'hasMany'

        it 'does not append "hasMany" relations to non-has-many relations', ->
            for entityName in ['instrument', 'song']
                rels = @result[entityName].relations
                for relProp, relInfo of rels
                    expect(relInfo.type).not.to.equal 'hasMany'
                    expect(relInfo.type).to.equal 'belongsTo'



    describe 'getAllEntityModels', ->

        it 'returns all entity models registered in the domain', ->
            classes = new SettingExporter(domain).getAllEntityModels()

            expect(classes.length).to.equal 3

            for klass in classes
                expect(klass::).to.be.instanceof Facade.Entity
                expect(klass.isEntity).to.be.true


    describe 'loadAll', ->

        it 'requires entity models in the domain dir', ->
            d = require('../create-facade').create(dirname: __dirname + '/../domains/music-live')
            expect(Object.keys d.classes).to.have.length 0
            new SettingExporter(d).loadAll()
            expect(Object.keys d.classes).to.have.length 12


module.exports = SettingExporter
