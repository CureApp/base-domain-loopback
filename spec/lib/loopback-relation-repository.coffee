
LoopbackRelationRepository = require('../../src/lib/loopback-relation-repository')
LoopbackRelatedClient = require('loopback-promised').LoopbackRelatedClient


domain = require('../create-facade').create()

class SampleModel extends domain.constructor.Entity
    @properties:
        date:   @TYPES.DATE
        parent: @TYPES.MODEL 'parent-model'

class ParentModel extends domain.constructor.Entity
    @properties:
        name: @TYPES.STRING

class SampleModelRepository extends LoopbackRelationRepository
    @modelName: 'sample-model'
    @belongsTo: 'parent'

domain.addClass('sample-model', SampleModel)
domain.addClass('parent-model', ParentModel)
domain.addClass('sample-model-repository', SampleModelRepository)


describe 'LoopbackRelationRepository', ->

    it 'has @belongsTo', ->
        expect(Object.keys LoopbackRelationRepository).to.contain 'belongsTo'


    it 'cannot be created when "belongsTo" is not set', ->
        class Repo extends LoopbackRelationRepository
            @modelName: 'sample-model'
            getFacade: -> domain

        expect(-> new Repo()).to.throw Error


    it 'cannot be create when "belongsTo" is not a prop name', ->
        class Repo extends LoopbackRelationRepository
            @modelName: 'sample-model'
            @belongsTo: 'parent-model'
            getFacade: -> domain

        expect(-> new Repo()).to.throw Error

    it 'is created when "belongsTo" is set', ->
        expect(-> domain.createRepository('sample-model')).not.to.throw Error

    it 'has foreignKeyName', ->
        repo = domain.createRepository('sample-model')

        expect(repo).to.have.property 'foreignKeyName', 'parentModelId'

    it 'has relClient', ->
        repo = domain.createRepository('sample-model', timeout: 300)

        expect(repo).to.have.property 'relClient'
        expect(repo.relClient).to.be.instanceof LoopbackRelatedClient
        expect(repo.relClient).to.have.property 'timeout', 300

    describe 'getClientByEntity', ->

        it 'returns relClient when it contains foreign key', ->
            repo = domain.createRepository('sample-model')
            entity = domain.createFactory('sample-model', true).createFromObject
                date: '1998-03-21'
                parent:
                    id: 'pnt'
                    name: 'pnt-name'

            expect(repo.getClientByEntity(entity)).to.equal repo.relClient

        it 'returns client when it does not contain foreign key', ->
            repo = domain.createRepository('sample-model')
            entity = domain.createFactory('sample-model', true).createFromObject
                date: '1998-03-21'
                parent:
                    name: 'pnt-name'

            expect(repo.getClientByEntity(entity)).to.equal repo.client


    describe 'getClientByForeignKey', ->

        it 'returns relClient when foreign key is passed', ->
            repo = domain.createRepository('sample-model')
            expect(repo.getClientByForeignKey(0)).to.equal repo.relClient

        it 'returns relClient when foreign key is not passed', ->
            repo = domain.createRepository('sample-model')
            expect(repo.getClientByForeignKey(null)).to.equal repo.client


    describe 'getClientByQuery', ->

        it 'returns relClient when query.where contains foreignKey and the value is not object', ->
            repo = domain.createRepository('sample-model')
            where =
                parentModelId: 123

            expect(repo.getClientByQuery(where: where)).to.equal repo.relClient

        it 'returns client when does not contain where', ->
            repo = domain.createRepository('sample-model')
            expect(repo.getClientByQuery({})).to.equal repo.client

        it 'returns client when query.where contains foreignKey but the value is object', ->
            repo = domain.createRepository('sample-model')
            where =
                parentModelId: gte: 122
            expect(repo.getClientByQuery(where: where)).to.equal repo.client

        it 'returns client when query.where does not contain foreignKey', ->
            repo = domain.createRepository('sample-model')
            where =
                and: [
                    parentModelId: 123
                ]
            expect(repo.getClientByQuery(where: where)).to.equal repo.client

