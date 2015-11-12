
{ LoopbackRepository } = require('../base-domain-loopback')
{ LoopbackClient } = require('loopback-promised')


describe 'LoopbackRepository', ->


    beforeEach ->

        @domain = require('../create-facade').create()

        class SampleModel extends @domain.constructor.Entity
            @properties:
                date:   @TYPES.DATE

        class SampleModelRepository extends LoopbackRepository
            @modelName: 'sample-model'

        @domain.addClass('sample-model', SampleModel)
        @domain.addClass('sample-model-repository', SampleModelRepository)


    describe ',about class properties,', ->

        it 'has aclType, default is "admin"', ->
            expect(LoopbackRepository.aclType).to.equal 'admin'

        it 'has empty lbModelName', ->
            expect(LoopbackRepository.lbModelName).to.equal ''


    it 'has client, instance of LoopbackClient', ->
        repo = @domain.createRepository('sample-model')
        expect(repo.client).to.be.instanceof LoopbackClient
        assert repo.client.timeout is undefined


    it 'has client, instance of LoopbackClient customized with options', ->
        options =
            timeout: 1000
            debug: false
            accessToken: 'abc'

        repo = @domain.createRepository('sample-model', options)
        expect(repo.client).to.be.instanceof LoopbackClient
        expect(repo.client).to.have.property 'timeout', 1000
        expect(repo.client).to.have.property 'debug', false
        expect(repo.client).to.have.property 'accessToken', 'abc'


    describe 'modifyDate', ->
        it 'convert date properties to valid date format', ->
            data =
                date : '1986-03-10'
            @domain.createRepository('sample-model').modifyDate(data)
            expect(data.date).to.match /1986-03-\d{2}T\d{2}:\d{2}:00\.000Z/


    describe 'save', ->
    # save: (entity) ->
    #     client = @getClientByEntity(entity)
    #     @modifyDate(entity)
    #     super(entity, client)
    describe 'get', ->
    # get: (id, foreignKey) ->
    #     client = @getClientByForeignKey(foreignKey)
    #     super(id, client)
    describe 'query', ->
    # query: (params) ->
    #     client = @getClientByQuery(params)
    #     super(params, client)
    describe 'singleQuery', ->
    # singleQuery: (params) ->
    #     client = @getClientByQuery(params)
    #     super(params, client)
    describe 'delete', ->
    # delete: (entity) ->
    #     client = @getClientByEntity(entity)
    #     super(entity, client)
    describe 'update', ->
    # update: (id, data) ->
    #     client = @getClientByEntity(data) # FIXME fails if data doesnt contain foreign key
    #     @modifyDate(data)
    #     super(id, data, client)
    describe 'getClientByEntity', ->
        it 'returns @client', ->
            repo = @domain.createRepository('sample-model')
            expect(repo.getClientByEntity()).to.equal repo.client


    describe 'getClientByForeignKey', ->
        it 'returns @client', ->
            repo = @domain.createRepository('sample-model')
            expect(repo.getClientByForeignKey()).to.equal repo.client


    describe 'getClientByQuery', ->
        it 'returns @client', ->
            repo = @domain.createRepository('sample-model')
            expect(repo.getClientByQuery()).to.equal repo.client


    describe 'parseSessionId', ->
        it 'split sessionId into accessToken and userId', ->
            repo = @domain.createRepository('sample-model')
            [ sessionId, userId ] = repo.parseSessionId('sessionId/userId')
            expect(sessionId).to.equal 'sessionId'
            expect(userId).to.equal 'userId'

