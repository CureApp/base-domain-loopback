'use strict';
var BaseAsyncRepository, Entity, LoopbackRepository, moment, ref, relationName,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

ref = require('base-domain'), BaseAsyncRepository = ref.BaseAsyncRepository, Entity = ref.Entity;

moment = require('moment');

relationName = require('./relation-name');


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
  Map to convert loopback's object prop into model prop
  
  key:   loopback's prop
  value: model prop
  
  if value is null or undefined, the property only exists in loopback and is removed from the created model.
  
  @property {Object} props
  @static
   */

  LoopbackRepository.props = null;


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
    facade = this.facade;
    lbModelName = this.constructor.getLbModelName();
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
    this.relClients = {};
  }


  /**
  get model name used in LoopBack
  @method getLbModelName
  @static
  @return {String}
   */

  LoopbackRepository.getLbModelName = function() {
    return this.lbModelName || this.modelName;
  };


  /**
  Create model instance from result from client
  
  @method createFromResult
  @protected
  @param {Object} obj
  @param {Object} [options]
  @return {BaseModel} model
   */

  LoopbackRepository.prototype.createFromResult = function(obj, options) {
    var lbProp, prop, ref1, ref2;
    if (obj == null) {
      return LoopbackRepository.__super__.createFromResult.apply(this, arguments);
    }
    ref2 = (ref1 = this.constructor.props) != null ? ref1 : {};
    for (lbProp in ref2) {
      prop = ref2[lbProp];
      if (prop != null) {
        obj[prop] = obj[lbProp];
      }
      delete obj[lbProp];
    }
    return LoopbackRepository.__super__.createFromResult.call(this, obj, options);
  };


  /**
  convert 'date' type property for loopback format
  
  @method modifyDate
  @private
  @param {Entity|Object} data
   */

  LoopbackRepository.prototype.modifyDate = function(data) {
    var dateProp, i, len, modelProps, ref1, val;
    modelProps = this.facade.getModelProps(this.getModelName());
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
  @param {Object} [options]
  @return {Promise(Entity)} entity (the same instance from input, if entity given,)
   */

  LoopbackRepository.prototype.save = function(entity, options) {
    if (options == null) {
      options = {};
    }
    if (!options.client && options.relation) {
      options.client = this.getRelatedClient(options.relation);
    } else {
      if (options.client == null) {
        options.client = this.getClientByEntity(entity);
      }
    }
    this.modifyDate(entity);
    return LoopbackRepository.__super__.save.call(this, entity, options);
  };


  /**
  get entity by id.
  
  @method get
  @public
  @param {String|Number} id
  @param {Object} [options]
  @param {String} [options.foreignKey]
  @return {Promise(Entity)} entity
   */

  LoopbackRepository.prototype.get = function(id, options) {
    if (options == null) {
      options = {};
    }
    if (!options.client && options.relation) {
      options.client = this.getRelatedClient(options.relation);
    } else {
      if (options.client == null) {
        options.client = this.getClientByForeignKey(options.foreignKey);
      }
    }
    return LoopbackRepository.__super__.get.call(this, id, options);
  };


  /**
  get entities by id.
  
  @method getByIds
  @public
  @param {Array|(String|Number)} ids
  @param {Object} [options]
  @return {Promise(Array(Entity))} entities
   */

  LoopbackRepository.prototype.getByIds = function(ids, options) {
    return this.query({
      where: {
        id: {
          inq: ids
        }
      }
    }, options);
  };


  /**
  Find all model instances that match params
  
  @method query
  @public
  @param {Object} [params] query parameters
  @param {Object} [options]
  @return {Promise(Array(Entity))} array of entities
   */

  LoopbackRepository.prototype.query = function(params, options) {
    if (params == null) {
      params = {};
    }
    if (options == null) {
      options = {};
    }
    if (params.relation && !options.relation) {
      options.relation = params.relation;
    }
    if (!options.client && options.relation) {
      options.client = this.getRelatedClient(options.relation);
    } else {
      if (options.client == null) {
        options.client = this.getClientByQuery(params);
      }
    }
    return LoopbackRepository.__super__.query.call(this, params, options);
  };


  /**
  Find one model instance that matches params, Same as query, but limited to one result
  
  @method singleQuery
  @public
  @param {Object} [params] query parameters
  @param {Object} [options]
  @return {Promise(Entity)} entity
   */

  LoopbackRepository.prototype.singleQuery = function(params, options) {
    if (options == null) {
      options = {};
    }
    if (!options.client && options.relation) {
      options.client = this.getRelatedClient(options.relation);
    } else {
      if (options.client == null) {
        options.client = this.getClientByQuery(params);
      }
    }
    return LoopbackRepository.__super__.singleQuery.call(this, params, options);
  };


  /**
  Destroy the given entity (which must have "id" value)
  
  @method delete
  @public
  @param {Entity} entity
  @param {Object} [options]
  @return {Promise(Boolean)} isDeleted
   */

  LoopbackRepository.prototype["delete"] = function(entity, options) {
    if (options == null) {
      options = {};
    }
    if (!options.client && options.relation) {
      options.client = this.getRelatedClient(options.relation);
    } else {
      if (options.client == null) {
        options.client = this.getClientByEntity(entity);
      }
    }
    return LoopbackRepository.__super__["delete"].call(this, entity, options);
  };


  /**
  Update set of attributes.
  
  @method update
  @public
  @param {any} id id of the entity to update
  @param {Object} data key-value pair to update
  @param {Object} [options]
  @return {Promise(Entity)} updated entity
   */

  LoopbackRepository.prototype.update = function(id, data, options) {
    if (options == null) {
      options = {};
    }
    if (!options.client && options.relation) {
      options.client = this.getRelatedClient(options.relation);
    } else {
      if (options.client == null) {
        options.client = this.getClientByEntity(data);
      }
    }
    this.modifyDate(data);
    return LoopbackRepository.__super__.update.call(this, id, data, options);
  };


  /**
  Update set of attributes and returns newly-updated props (other than `props`)
  
  @method updateProps
  @public
  @param {Entity} entity
  @param {Object} data key-value pair to update (notice: this must not be instance of Entity)
  @param {Object} [options]
  @param {ResourceClientInterface} [options.client=@client]
  @return {Object} updated props
   */

  LoopbackRepository.prototype.updateProps = function(entity, props, options) {
    if (props == null) {
      props = {};
    }
    if (options == null) {
      options = {};
    }
    if (!options.client && options.relation) {
      options.client = this.getRelatedClient(options.relation);
    } else {
      if (options.client == null) {
        options.client = this.getClientByEntity(props);
      }
    }
    this.modifyDate(props);
    return LoopbackRepository.__super__.updateProps.call(this, entity, props, options);
  };


  /**
  Return the number of models that match the optional "where" filter.
  
  @method count
  @public
  @param {Object} [where]
  @return {Promise(Number)}
   */

  LoopbackRepository.prototype.count = function(where, options) {
    var client;
    if (where == null) {
      where = {};
    }
    if (options == null) {
      options = {};
    }
    if (options.client) {
      client = options.client;
    } else if (options.relation) {
      client = this.getRelatedClient(options.relation);
    } else {
      if (client == null) {
        client = this.getClientByQuery({
          where: where
        });
      }
    }
    return client.count(where);
  };


  /**
  Get loopback-related-client
  @method getRelatedClient
  @protected
  @param {Object} params
  @param {String} params.modelName foreign model name
  @param {String} params.id foreign id
  @param {String} [params.relation] relation name
  @param {String} [params.foreignKey] foreign key prop.
  @param {String} [params.through]
  @param {String} [params.keyThrough]
  @return {LoopbackRelatedClient}
   */

  LoopbackRepository.prototype.getRelatedClient = function(params) {
    var Repo, client, clientKey, e, error, foreignKey, id, keyThrough, model, name, relClientOptions, relName, through;
    if (params == null) {
      params = {};
    }
    model = params.model, name = params.name, id = params.id, foreignKey = params.foreignKey, through = params.through, keyThrough = params.keyThrough;
    if (!model) {
      return null;
    }
    relName = name != null ? name : relationName({
      model: this.constructor.getLbModelName(),
      foreignKey: foreignKey,
      through: through,
      keyThrough: keyThrough
    });
    clientKey = model + '.' + relName;
    if (client = this.relClients[clientKey]) {
      client.setId(id);
      return client;
    }
    try {
      Repo = this.facade.require(model + '-repository');
      if (!(Repo.prototype instanceof LoopbackRepository)) {
        throw new Error();
      }
    } catch (error) {
      e = error;
      console.error("Error in LoopbackRepository#getRelatedClient(). '" + model + "-repository' is not found,\nor it is not an instance of LoopbackRepository.\nmodel name must be compatible with LoopbackRepository when querying with relation.");
      return null;
    }
    relClientOptions = {
      one: Repo.getLbModelName(),
      many: relName,
      id: id,
      accessToken: this.client.accessToken,
      timeout: this.client.timeout,
      debug: this.client.debug
    };
    return this.relClients[clientKey] = this.facade.lbPromised.createRelatedClient(relClientOptions);
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
