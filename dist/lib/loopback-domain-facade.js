'use strict';
var Facade, LoopbackDomainFacade, LoopbackPromised,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

LoopbackPromised = require('loopback-promised');

Facade = require('base-domain');


/**
@class LoopbackDomainFacade
@extends Facade
@module base-domain-loopback
 */

LoopbackDomainFacade = (function(superClass) {
  extend(LoopbackDomainFacade, superClass);


  /**
  constructor
  
  @param {Object} [options]
  @param {String} options.baseURL loopback api root
  @param {String} options.sessionId
  @param {Boolean} options.debug
   */

  function LoopbackDomainFacade(options) {
    if (options == null) {
      options = {};
    }
    LoopbackDomainFacade.__super__.constructor.call(this, options);
    this.debug = !!options.debug;
    this.lbPromised = LoopbackPromised.createInstance({
      baseURL: options.baseURL
    });
    this.sessionId = options.sessionId;
    this.timeout = options.timeout;
  }


  /**
  set sessionId. Repositories generated after setSessionId(newSessionIDs) use the new sessionId
  
  @method setSessionId
  @param {String} sessionId
   */

  LoopbackDomainFacade.prototype.setSessionId = function(sessionId) {
    this.sessionId = sessionId;
  };


  /**
  set baseURL. Repositories generated after setBaseURL(newBaseURL) use the new baseURL
  
  @method setBaseURL
  @param {String} baseURL
   */

  LoopbackDomainFacade.prototype.setBaseURL = function(baseURL) {
    this.lbPromised.baseURL = baseURL;
  };


  /**
  Get model definition objects, which [loopback-with-admin](https://github.com/CureApp/loopback-with-admin))))
  
  @method getModelDefinitions
  @return {Object}
   */

  LoopbackDomainFacade.prototype.getModelDefinitions = function() {
    return new this.constructor.SettingExporter(this)["export"]();
  };

  LoopbackDomainFacade.LoopbackRepository = require('./loopback-repository');

  LoopbackDomainFacade.LoopbackUserRepository = require('./loopback-user-repository');

  LoopbackDomainFacade.LoopbackRelationRepository = require('./loopback-relation-repository');

  LoopbackDomainFacade.SettingExporter = require('./setting-exporter');

  return LoopbackDomainFacade;

})(Facade);

module.exports = LoopbackDomainFacade;
