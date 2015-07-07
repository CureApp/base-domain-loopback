
{ Entity } = require 'base-domain'

class Staff extends Entity

    @properties:
        name: @TYPES.STRING
        role: @TYPES.STRING

module.exports = Staff
