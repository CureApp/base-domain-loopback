/*
 * transformer for browserify
 * preloads all the domain files in the directory you set
 *
 * usage
 *
 * browserify -t [ base-domain-loopback/ify --dirname /path/to/domain/dir ]
 */

require('coffee-script/register');
module.exports = require('./src/base-domain-loopbackify.coffee');
