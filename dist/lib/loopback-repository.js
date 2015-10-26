var BaseAsyncRepository, Entity, LoopbackRepository, moment, ref,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

ref = require('base-domain'), BaseAsyncRepository = ref.BaseAsyncRepository, Entity = ref.Entity;

moment = require('moment');


/**
@class LoopbackRepository
@extends BaseAsyncRepository
@module base-domain-loopback
 */

LoopbackRepository = (function(superClass) {
  extend(LoopbackRepository, superClass);


  /**
  aclType : type of access control list in [loopback-with-admin](https://github.com/cureapp/loopback-with-admin)
   */

  LoopbackRepository.aclType = 'admin';


  /**
  model name used in Loopback
  it will be the same value as @modelName if not set
  
  @property lbModelName
  @static
  @type String
   */

  LoopbackRepository.lbModelName = '';


  /**
  constructor
  
  @constructor
  @param {Object}  [options]
  @param {String}  [options.sessionId] Session ID
  @param {Boolean} [options.debug] shows debug log if true
  @params {RootInterface} root
   */

  function LoopbackRepository(options, root) {
    var accessToken, facade, lbModelName, ref1, sessionId, userId;
    if (options == null) {
      options = {};
    }
    LoopbackRepository.__super__.constructor.call(this, root);
    facade = this.getFacade();
    lbModelName = this.constructor.lbModelName || this.constructor.modelName;
    sessionId = options.sessionId || facade.sessionId;
    ref1 = this.parseSessionId(sessionId), accessToken = ref1[0], userId = ref1[1];
    if (options.accessToken == null) {
      options.accessToken = accessToken;
    }
    if (options.debug == null) {
      options.debug = facade.debug;
    }
    if (options.timeout == null) {
      options.timeout = facade.timeout;
    }
    this.client = facade.lbPromised.createClient(lbModelName, options);
  }


  /**
  convert 'date' type property for loopback format
  
  @method modifyDate
  @private
  @param {Entity|Object} data
   */

  LoopbackRepository.prototype.modifyDate = function(data) {
    var dateProp, i, len, modelProps, ref1, val;
    modelProps = this.getFacade().getModelProps(this.getModelName());
    ref1 = modelProps.dates;
    for (i = 0, len = ref1.length; i < len; i++) {
      dateProp = ref1[i];
      val = data[dateProp];
      if (val != null) {
        data[dateProp] = moment(val).toISOString();
      }
    }
  };


  /**
  Update or insert a model instance
  
  @method save
  @public
  @param {Entity|Object} entity
  @return {Promise(Entity)} entity (the same instance from input, if entity given,)
   */

  LoopbackRepository.prototype.save = function(entity) {
    var client;
    client = this.getClientByEntity(entity);
    this.modifyDate(entity);
    return LoopbackRepository.__super__.save.call(this, entity, client);
  };


  /**
  get entity by id.
  
  @method get
  @public
  @param {String|Number} id
  @param {String} foreignKey
  @return {Promise(Entity)} entity
   */

  LoopbackRepository.prototype.get = function(id, foreignKey) {
    var client;
    client = this.getClientByForeignKey(foreignKey);
    return LoopbackRepository.__super__.get.call(this, id, client);
  };


  /**
  get entities by id.
  
  @method getByIds
  @public
  @param {Array|(String|Number)} ids
  @return {Promise(Array(Entity))} entities
   */

  LoopbackRepository.prototype.getByIds = function(ids) {
    return this.query({
      where: {
        id: {
          inq: ids
        }
      }
    });
  };


  /**
  Find all model instances that match params
  
  @method query
  @public
  @param {Object} [params] query parameters
  @return {Promise(Array(Entity))} array of entities
   */

  LoopbackRepository.prototype.query = function(params) {
    var client;
    client = this.getClientByQuery(params);
    return LoopbackRepository.__super__.query.call(this, params, client);
  };


  /**
  Find one model instance that matches params, Same as query, but limited to one result
  
  @method singleQuery
  @public
  @param {Object} [params] query parameters
  @return {Promise(Entity)} entity
   */

  LoopbackRepository.prototype.singleQuery = function(params) {
    var client;
    client = this.getClientByQuery(params);
    return LoopbackRepository.__super__.singleQuery.call(this, params, client);
  };


  /**
  Destroy the given entity (which must have "id" value)
  
  @method delete
  @public
  @param {Entity} entity
  @return {Promise(Boolean)} isDeleted
   */

  LoopbackRepository.prototype["delete"] = function(entity) {
    var client;
    client = this.getClientByEntity(entity);
    return LoopbackRepository.__super__["delete"].call(this, entity, client);
  };


  /**
  Update set of attributes.
  
  @method update
  @public
  @param {any} id id of the entity to update
  @param {Object} data key-value pair to update
  @return {Promise(Entity)} updated entity
   */

  LoopbackRepository.prototype.update = function(id, data) {
    var client;
    client = this.getClientByEntity(data);
    this.modifyDate(data);
    return LoopbackRepository.__super__.update.call(this, id, data, client);
  };


  /**
  Return the number of models that match the optional "where" filter.
  
  @method count
  @public
  @param {Object} [where]
  @return {Promise(Number)}
   */

  LoopbackRepository.prototype.count = function(where) {
    var client;
    if (where == null) {
      where = {};
    }
    client = this.getClientByQuery({
      where: where
    });
    return client.count(where);
  };


  /**
  get client by entity. By default it returns @client
  
  @method getClientByEntity
  @protected
  @param {Entity|Object} entity
  @return {LoopbackClient} client
   */

  LoopbackRepository.prototype.getClientByEntity = function(entity) {
    return this.client;
  };


  /**
  get client by foreign key. By default it returns @client
  
  @method getClientByForeignKey
  @protected
  @param {String} foreignKey
  @return {LoopbackClient} client
   */

  LoopbackRepository.prototype.getClientByForeignKey = function(foreignKey) {
    return this.client;
  };


  /**
  get client by query value. By default it returns @client
  
  @method getClientByQuery
  @protected
  @param {Object} query
  @return {LoopbackClient} client
   */

  LoopbackRepository.prototype.getClientByQuery = function(query) {
    return this.client;
  };


  /**
  get accessToken and userId by sessionId
  
  @method parseSessionId
  @protected
  @param {String} sessionId
  @return {Array(String)} [accessToken, userId]
   */

  LoopbackRepository.prototype.parseSessionId = function(sessionId) {
    if (!sessionId) {
      return [null, null];
    }
    return sessionId.split('/');
  };

  return LoopbackRepository;

})(BaseAsyncRepository);

module.exports = LoopbackRepository;
