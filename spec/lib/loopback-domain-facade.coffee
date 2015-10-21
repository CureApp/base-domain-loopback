
LoopbackDomainFacade = require('../../src/lib/loopback-domain-facade')

describe 'LoopbackDomainFacade', ->

    it 'has "debug" property (default: false)', ->
        expect(new LoopbackDomainFacade()).to.have.property 'debug', false


    it 'has "debug" property, true if option.debug is true', ->
        expect(new LoopbackDomainFacade(debug: true)).to.have.property 'debug', true


    it 'has loopback promised', ->
        expect(new LoopbackDomainFacade()).to.have.property 'lbPromised'
        expect(new LoopbackDomainFacade().lbPromised).to.be.instanceof require('loopback-promised')


    it 'has loopback promised with baseURL', ->
        expect(new LoopbackDomainFacade(baseURL: 'localhost').lbPromised).to.have.property 'baseURL', 'localhost'


    it 'has sessionId if set', ->
        expect(new LoopbackDomainFacade(sessionId: 'ab/c')).to.have.property 'sessionId', 'ab/c'


    describe 'setSessionId', ->
        it 'sets sessionId to this instance', ->
            domain = new LoopbackDomainFacade(sessionId: 'ab/c')
            domain.setSessionId('bc/d')
            expect(domain).to.have.property 'sessionId', 'bc/d'


    describe 'setBaseURL', ->
        it 'sets baseURL to lbPromised', ->
            domain = new LoopbackDomainFacade(baseURL: 'localhost')
            domain.setBaseURL('localhost:3000/api')
            expect(domain.lbPromised).to.have.property 'baseURL', 'localhost:3000/api'

