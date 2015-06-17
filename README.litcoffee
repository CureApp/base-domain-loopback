# base-domain-loopback

Domain-Driven Design with [loopback](http://docs.strongloop.com/display/public/LB/LoopBack)


extends [base-domain](https://github.com/cureapp/base-domain)

# installation

```bash
$ npm install base-domain-loopback
```


# usage
## definition

model definition is the same as [base-domain](https://github.com/cureapp/base-domain)

domain-dir/player.coffee

    Domain = require('base-domain-loopback')

    class Player extends Domain.Entity
        @properties:
            name: @TYPES.STRING

    module.exports = Player

domain-dir/player-repository.coffee

    Domain = require('base-domain-loopback')

    class PlayerRepository extends Domain.LoopbackUserRepository
        @aclType: 'owner' # access type. see README in loopback-with-admin

main.coffee

    domain = require('base-domain-loopback').createInstance
        dirname: 'domain-dir'
        baseURL: 'localhost:4157/api'


## run loopback server with loopback-with-admin

    domain = require('base-domain-loopback').createInstance dirname: 'domain-dir'

    modelDefinitions = domain.getModelDefinitions()

    config =
        server:
            port: 4157

    require('loopback-with-admin').run(modelDefinitions, config)


