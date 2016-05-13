
Facade = require './base-domain-loopback'

domain = Facade.createInstance dirname: __dirname + '/domains/music-live', debug: false

modelDefinitions = domain.getModelDefinitions()

before ->

    @timeout 10000

    require('loopback-with-admin').run(modelDefinitions).then (lbInfo) ->

        domain.setBaseURL lbInfo.getURL()
        domain.setSessionId lbInfo.getAdminTokens()[0]



describe 'domain', ->

    it 'can access to loopback', ->

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
            assert song instanceof domain.getModel 'song'


    it 'can get 1:N-related object', ->

        domain.createRepository('song').query(where: authorId: 'shin').then (songs) ->
            assert songs.length is 1


    it 'can get N:1-related object', ->

        domain.createRepository('song').singleQuery(where: {id: 'lowdown'}, include: 'author').then (song) ->
            assert song.author instanceof domain.getModel 'player'

    it 'can login', ->
        domain.createRepository('player').login('shinout@shinout.com', 'shinout').then (result) =>
            @sessionId = result.sessionId
            assert @sessionId.match /\/shin$/
            assert result.ttl is modelDefinitions.models.player.ttl

    it 'can access to "owner" aclType models', ->

        domain.setSessionId @sessionId

        domain.createRepository('song').query(where: authorId: 'shin').then (songs) ->
            assert songs.length is 1


