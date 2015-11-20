'use strict'
/*
 * transformer for browserify
 * preloads all the domain files in the directory you set
 *
 * usage
 *
 * browserify -t [ base-domain-loopback/ify --dirname /path/to/domain/dir ]
 */


var BaseDomainify = require('base-domain/ify').BaseDomainify;

var baseDomainLoopbackify = new BaseDomainify('base-domain-loopback')

module.exports = function(file, options) {
    return baseDomainLoopbackify.run(file, options);
};

module.exports.BaseDomainify = BaseDomainify
