
Facade = require './base-domain-loopback'

domain = Facade.createInstance dirname: __dirname + '/domains/music-live', debug: false

modelDefinitions = domain.getModelDefinitions()

modelDefinitions.player.ttl = 24 * 3600 * 365 * 10
modelDefinitions.player.maxTTL = 24 * 3600 * 365 * 100

before (done) ->

    @timeout 10000

    require('loopback-with-admin').run(modelDefinitions).then (lbInfo) ->

        domain.setBaseURL lbInfo.getURL()
        domain.setSessionId lbInfo.getAccessToken()

        done()


describe 'domain', ->

    it 'can access to loopback', (done) ->

        playerObj =
            id: 'shin'
            name: 'shin'
            email: 'shinout@shinout.com'
            password: 'shinout'

        domain.createRepository('player').save(playerObj).then (player) ->
            songObj =
                id: 'lowdown'
                name: 'lowdown'
                author: player
            domain.createRepository('song').save(songObj)

        .then (song) ->
            expect(song).to.be.instanceof domain.getModel 'song'
            done()


    it 'can get 1:N-related object', (done) ->

        domain.createRepository('song').query(where: authorId: 'shin').then (songs) ->
            expect(songs).to.have.length 1
            done()


    it 'can get N:1-related object', (done) ->

        domain.createRepository('song').singleQuery(where: {id: 'lowdown'}, include: 'author').then (song) ->
            expect(song.author).to.be.instanceof domain.getModel 'player'
            done()

    it 'can login', (done) ->
        domain.createRepository('player').login('shinout@shinout.com', 'shinout').then (result) =>
            @sessionId = result.sessionId
            expect(@sessionId).to.match /\/shin$/
            expect(result.ttl).to.equal modelDefinitions.player.ttl
            done()

    it 'can access to "owner" aclType models', (done) ->

        domain.setSessionId @sessionId

        domain.createRepository('song').query(where: authorId: 'shin').then (songs) ->
            expect(songs).to.have.length 1
            done()


