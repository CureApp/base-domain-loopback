
LoopbackUserRepository = require('../../src/lib/loopback-user-repository')
LoopbackUserClient = require('loopback-promised').LoopbackUserClient
Promise = require('loopback-promised').Promise

domain = require('../create-facade').create()

class SampleModel extends domain.constructor.Entity
    @properties:
        date:   @TYPES.DATE
        parent: @TYPES.MODEL 'parent-model'

class SampleModelRepository extends LoopbackUserRepository
    @modelName: 'sample-model'

domain.addClass('sample-model', SampleModel)
domain.addClass('sample-model-repository', SampleModelRepository)


describe 'LoopbackUserClient', ->

    it 'has client, instance of LoopbackUserClient', ->
        repo = domain.createRepository('sample-model')
        expect(repo.client).to.be.instanceof LoopbackUserClient

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
            repo = domain.createRepository('sample-model')
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
