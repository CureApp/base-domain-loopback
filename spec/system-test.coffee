
Facade = require './base-domain-loopback'

domain = Facade.createInstance dirname: __dirname + '/domains/music-live', debug: true

modelDefinitions = domain.getModelDefinitions()

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
