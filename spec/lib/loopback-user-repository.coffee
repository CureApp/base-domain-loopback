
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

        @domain.addClass(SampleModel)
        @domain.addClass(SampleModelRepository)


    it 'has client, instance of LoopbackUserClient', ->
        repo = @domain.createRepository('sample-model')
        expect(repo.client).to.be.instanceof LoopbackUserClient

    it 'has client, instance of LoopbackUserClient with custom options', ->
        repo = @domain.createRepository('sample-model', timeout: 100)
        expect(repo.client).to.be.instanceof LoopbackUserClient
        expect(repo.client).to.have.property 'timeout', 100

    describe 'login', ->

        xit 'cannot login without email or password', (done) ->
            done()

        xit 'cannot login with invalid email or password', (done) ->
            done()

        xit 'logins with email and password', (done) ->
            done()


    describe 'getBySessionId', ->
        xit 'cannot fetch a user model by invalid sessionId', (done) ->
            done()

        xit 'fetchs a user model by valid sessionId', (done) ->
            done()

    describe 'logout', ->
        xit 'succeeds even when sessionId is not valid', (done) ->
            done()


    describe 'confirm', ->
        it 'returns boolean, depends on success of login, logout', (done) ->
            repo = @domain.createRepository('sample-model')
            repo.login  = -> Promise.resolve {}
            repo.logout = -> Promise.resolve {}
            repo.confirm().then (result) ->

                expect(result).to.be.true

                repo.login = -> Promise.reject new Error()
                repo.confirm()

            .then (result) ->
                expect(result).to.be.false
                done()
            .catch done
