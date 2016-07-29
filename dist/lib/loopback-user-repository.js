'use strict';
var LoopbackRepository, LoopbackUserRepository,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

LoopbackRepository = require('./loopback-repository');


/**
@class LoopbackUserRepository
@extends LoopbackRepository
@module base-domain-loopback
 */

LoopbackUserRepository = (function(superClass) {
  extend(LoopbackUserRepository, superClass);


  /**
  constructor
  
  @constructor
  @param {Object}  [options]
  @param {String}  [options.sessionId] Session ID
  @param {Boolean} [options.debug] shows debug log if true
   */

  function LoopbackUserRepository(options, root) {
    var modelName;
    if (options == null) {
      options = {};
    }
    LoopbackUserRepository.__super__.constructor.call(this, options, root);
    modelName = this.constructor.modelName;
    this.client = this.facade.lbPromised.createUserClient(modelName, options);
  }


  /**
  get sessionId from account information (email/password)
  
  @param {String} email
  @param {String} password
  @param {Boolean|String} [include] fetch related model if true. fetch submodels if 'include'. fetch submodels recursively if 'recursive'
  @return {Promise(Object)}
   */

  LoopbackUserRepository.prototype.login = function(email, password, include) {
    var facade, includeUser;
    facade = this.facade;
    includeUser = include != null;
    return this.client.login({
      email: email,
      password: password
    }, includeUser ? 'user' : null).then((function(_this) {
      return function(response) {
        var accessToken, model, oldSessionId, ret, userId;
        accessToken = response.id;
        userId = includeUser ? response.user.id : response.userId;
        ret = {
          sessionId: accessToken + '/' + userId,
          ttl: response.ttl
        };
        if (includeUser) {
          model = _this.factory.createFromObject(response.user);
          ret[_this.constructor.modelName] = model;
          if (include === 'include') {
            oldSessionId = facade.sessionId;
            facade.setSessionId(ret.sessionId);
            return model.include({
              accessToken: accessToken
            }).then(function() {
              ret[_this.constructor.modelName] = model;
              facade.setSessionId(oldSessionId);
              return ret;
            });
          } else if (include === 'recursive') {
            return model.include({
              accessToken: accessToken,
              recursive: true
            }).then(function() {
              ret[_this.constructor.modelName] = model;
              facade.setSessionId(oldSessionId);
              return ret;
            });
          } else {
            ret[_this.constructor.modelName] = model;
            return ret;
          }
        } else {
          return ret;
        }
      };
    })(this));
  };


  /**
  logout (delete session)
  
  @param {String} sessionId
  @return {Promise}
   */

  LoopbackUserRepository.prototype.logout = function(sessionId) {
    var accessToken, client, ref, userId;
    ref = this.parseSessionId(sessionId), accessToken = ref[0], userId = ref[1];
    client = this.facade.lbPromised.createUserClient(this.constructor.modelName, {
      debug: this.client.debug,
      accessToken: accessToken
    });
    return client.logout(accessToken);
  };


  /**
  get user model by sessionId
  
  @method getBySessionId
  @param {String} sessionId
  @param {Object} [options]
  @param {Boolean|String} [options.include] include related models or not. if 'recursive' is set, recursively fetches submodels
  @return {Promise(Entity)}
   */

  LoopbackUserRepository.prototype.getBySessionId = function(sessionId, options) {
    var accessToken, client, ref, userId;
    if (options == null) {
      options = {};
    }
    ref = this.parseSessionId(sessionId), accessToken = ref[0], userId = ref[1];
    client = this.facade.lbPromised.createUserClient(this.constructor.modelName, {
      debug: this.client.debug,
      accessToken: accessToken
    });
    return client.findById(userId).then((function(_this) {
      return function(user) {
        var facade, model, oldSessionId;
        model = _this.factory.createFromObject(user);
        if (options.include) {
          facade = _this.facade;
          oldSessionId = facade.sessionId;
          facade.setSessionId(sessionId);
          return model.include({
            recursive: options.include === 'recursive'
          }).then(function() {
            facade.setSessionId(oldSessionId);
            return model;
          });
        } else {
          return model;
        }
      };
    })(this))["catch"](function(e) {
      if (e.isLoopbackResponseError) {
        return null;
      }
      throw e;
    });
  };


  /**
  confirm existence of account by email and password
  
  @param {String} email
  @param {String} password
  @return {Promise(Boolean)} existence of the account
   */

  LoopbackUserRepository.prototype.confirm = function(email, password) {
    return this.login(email, password).then((function(_this) {
      return function(result) {
        return _this.logout(result.sessionId).then(function() {
          return true;
        });
      };
    })(this))["catch"](function(e) {
      return false;
    });
  };


  /**
  Override original method.
  Enable to preserve password property using `__password` option.
  Mainly for immutable entities.
   */

  LoopbackUserRepository.prototype.createFromResult = function(obj, options) {
    if (options == null) {
      options = {};
    }
    if (options.__password == null) {
      return LoopbackUserRepository.__super__.createFromResult.apply(this, arguments);
    }
    obj.password = options.__password;
    return LoopbackUserRepository.__super__.createFromResult.call(this, obj, options);
  };


  /**
  Update or insert a model instance
  reserves password property, as loopback does not return password
  
  @method save
  @public
  @param {Entity|Object} entity
  @return {Promise(Entity)} entity (the same instance from input, if entity given,)
   */

  LoopbackUserRepository.prototype.save = function(entity, options) {
    if (options == null) {
      options = {};
    }
    options.__password = entity != null ? entity.password : void 0;
    return LoopbackUserRepository.__super__.save.call(this, entity, options);
  };

  return LoopbackUserRepository;

})(LoopbackRepository);

module.exports = LoopbackUserRepository;
