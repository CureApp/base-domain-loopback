
{ LoopbackUserRepository, Entity } = require('../base-domain-loopback')
{ Promise, LoopbackUserClient } = require('loopback-promised')


describe 'LoopbackUserClient', ->

    beforeEach ->

        @domain = require('../create-facade').create()

        class SampleModel extends Entity
            @properties:
                date:   @TYPES.DATE

        class SampleModelRepository extends LoopbackUserRepository
            @modelName: 'sample-model'

        @domain.addClass('sample-model', SampleModel)
        @domain.addClass('sample-model-repository', SampleModelRepository)


    it 'has client, instance of LoopbackUserClient', ->
        repo = @domain.createRepository('sample-model')
        assert repo.client instanceof LoopbackUserClient

    it 'has client, instance of LoopbackUserClient with custom options', ->
        repo = @domain.createRepository('sample-model', timeout: 100)
        assert repo.client instanceof LoopbackUserClient
        assert repo.client.timeout is 100

    describe 'login', ->

        xit 'cannot login without email or password', ->

        xit 'cannot login with invalid email or password', ->

        xit 'logins with email and password', ->


    describe 'getBySessionId', ->
        xit 'cannot fetch a user model by invalid sessionId', ->

        xit 'fetchs a user model by valid sessionId', ->

    describe 'logout', ->
        xit 'succeeds even when sessionId is not valid', ->


    describe 'confirm', ->
        it 'returns boolean, depends on success of login, logout', ->
            repo = @domain.createRepository('sample-model')
            repo.login  = -> Promise.resolve {}
            repo.logout = -> Promise.resolve {}
            repo.confirm().then (result) ->

                assert result

                repo.login = -> Promise.reject new Error()
                repo.confirm()

            .then (result) ->
                assert result is false
