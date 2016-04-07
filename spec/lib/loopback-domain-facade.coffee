
LoopbackDomainFacade = require('../../src/lib/loopback-domain-facade')

describe 'LoopbackDomainFacade', ->

    beforeEach ->
        @domain = new LoopbackDomainFacade()

    it 'has "debug" property (default: false)', ->
        assert @domain.debug is false


    it 'has "debug" property, true if option.debug is true', ->
        domain = new LoopbackDomainFacade(debug: true)
        assert domain.debug


    it 'has loopback promised', ->
        assert @domain.lbPromised?
        assert @domain.lbPromised instanceof require('loopback-promised')


    it 'has loopback promised with baseURL', ->
        domain =  new LoopbackDomainFacade(baseURL: 'localhost')
        assert domain.lbPromised.baseURL is 'localhost'


    it 'has sessionId if set', ->
        domain = new LoopbackDomainFacade(sessionId: 'ab/c')
        assert domain.sessionId is 'ab/c'


    describe 'setSessionId', ->
        it 'sets sessionId to this instance', ->
            domain = new LoopbackDomainFacade(sessionId: 'ab/c')
            domain.setSessionId('bc/d')
            assert domain.sessionId is 'bc/d'


    describe 'setBaseURL', ->
        it 'sets baseURL to lbPromised', ->
            domain = new LoopbackDomainFacade(baseURL: 'localhost')
            domain.setBaseURL('localhost:3000/api')
            assert domain.lbPromised.baseURL is 'localhost:3000/api'

