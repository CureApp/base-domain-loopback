/*
 * transformer for browserify
 * preloads all the domain files in the directory you set
 *
 * usage
 *
 * browserify -t [ base-domain-loopback/ify --dirname /path/to/domain/dir ]
 */

require('coffee-script/register');

var BaseDomainLoopbackify = require('./src/base-domain-loopbackify.coffee');
var baseDomainLoopbackify = new BaseDomainLoopbackify()

module.exports = function(file, options) {
    return baseDomainLoopbackify.run(file, options);
};
