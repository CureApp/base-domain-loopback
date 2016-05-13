
{ LoopbackRelationRepository, LoopbackRepository, Entity } = require('../base-domain-loopback')
{ LoopbackRelatedClient } = require('loopback-promised')


describe 'LoopbackRelationRepository', ->

    beforeEach ->

        @domain = require('../create-facade').create()

        class SampleModel extends Entity
            @properties:
                date:   @TYPES.DATE
                parent: @TYPES.MODEL 'parent-model'

        class ParentModel extends Entity
            @properties:
                name: @TYPES.STRING

        class SampleModelRepository extends LoopbackRelationRepository
            @modelName: 'sample-model'
            @belongsTo: 'parent'

        class ParentModelRepository extends LoopbackRepository
            @modelName: 'parent-model'

        @domain.addClass('sample-model', SampleModel)
        @domain.addClass('parent-model', ParentModel)
        @domain.addClass('sample-model-repository', SampleModelRepository)
        @domain.addClass('parent-model-repository', ParentModelRepository)



    it 'has @belongsTo', ->
        assert LoopbackRelationRepository.hasOwnProperty 'belongsTo'


    it 'cannot be created when "belongsTo" is not set', ->
        class Repo extends LoopbackRelationRepository
            @modelName: 'sample-model'
        @domain.addClass('sample-model-repository', Repo)

        assert.throws (=> new Repo({}, @domain)), 'You must set @belongsTo and @foreignKeyName when extending RelationRepository.'


    it 'cannot be create when "belongsTo" is not a prop name', ->
        class Repo extends LoopbackRelationRepository
            @modelName: 'sample-model'
            @belongsTo: 'parent-model'

        @domain.addClass('sample-model-repository', Repo)

        assert.throws (=> new Repo({}, @domain)), '"belongsTo" property: parent-model is not an entity prop.'


    it 'is created when "belongsTo" is set', ->
        @domain.createRepository('sample-model')

    it 'has foreignKeyName', ->
        repo = @domain.createRepository('sample-model')

        assert repo.foreignKeyName is 'parentModelId'

    it 'has relClient', ->
        repo = @domain.createRepository('sample-model', timeout: 300)

        assert repo.relClient?
        assert repo.relClient instanceof LoopbackRelatedClient
        assert repo.relClient.timeout is 300

    describe 'getClientByEntity', ->

        it 'returns relClient when it contains foreign key', ->
            repo = @domain.createRepository('sample-model')
            entity = @domain.createModel 'sample-model',
                date: '1998-03-21'
                parent:
                    id: 'pnt'
                    name: 'pnt-name'

            assert repo.getClientByEntity(entity) is repo.relClient

        it 'returns client when it does not contain foreign key', ->
            repo = @domain.createRepository('sample-model')
            entity = @domain.createModel 'sample-model',
                date: '1998-03-21'
                parent:
                    name: 'pnt-name'

            assert repo.getClientByEntity(entity) is repo.client


    describe 'getClientByForeignKey', ->

        it 'returns relClient when foreign key is passed', ->
            repo = @domain.createRepository('sample-model')
            assert repo.getClientByForeignKey(0) is repo.relClient

        it 'returns relClient when foreign key is not passed', ->
            repo = @domain.createRepository('sample-model')
            assert repo.getClientByForeignKey(null) is repo.client


    describe 'getClientByQuery', ->

        it 'returns relClient when query.where contains foreignKey and the value is not object', ->
            repo = @domain.createRepository('sample-model')
            where =
                parentModelId: 123

            assert repo.getClientByQuery(where: where) is repo.relClient

        it 'returns client when does not contain where', ->
            repo = @domain.createRepository('sample-model')
            assert repo.getClientByQuery({}) is repo.client

        it 'returns client when query.where contains foreignKey but the value is object', ->
            repo = @domain.createRepository('sample-model')
            where =
                parentModelId: gte: 122
            assert repo.getClientByQuery(where: where) is repo.client

        it 'returns client when query.where does not contain foreignKey', ->
            repo = @domain.createRepository('sample-model')
            where =
                and: [
                    parentModelId: 123
                ]
            assert repo.getClientByQuery(where: where) is repo.client

