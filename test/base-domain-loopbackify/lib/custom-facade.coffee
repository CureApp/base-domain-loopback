
Facade = require('base-domain-loopback')

class CustomFacade extends Facade

    constructor: ->
        super
        @isCustom = true

module.exports = CustomFacade
