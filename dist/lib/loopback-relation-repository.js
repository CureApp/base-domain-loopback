'use strict';
var LoopbackRelationRepository, LoopbackRepository,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

LoopbackRepository = require('./loopback-repository');


/**
@class LoopbackUserRepository
@extends LoopbackRepository
@module base-domain-loopback
 */

LoopbackRelationRepository = (function(superClass) {
  extend(LoopbackRelationRepository, superClass);


  /**
  prop name this model belongs to
  
  @property belongsTo
  @protected
  @type String
   */

  LoopbackRelationRepository.belongsTo = null;


  /**
  constructor
  
  @constructor
  @param {Object} [options]
  @param {any} [options.id] the id of the "belongsTo" model
  @param {String}  [options.sessionId] Session ID
  @param {Boolean} [options.debug] shows debug log if true
   */

  function LoopbackRelationRepository(options, root) {
    var belongsTo, hasSameSubModel, modelProps, subIdName, subModelName;
    if (options == null) {
      options = {};
    }
    if (!this.constructor.belongsTo) {
      throw new Error("You must set @belongsTo and @foreignKeyName when extending RelationRepository.");
    }
    LoopbackRelationRepository.__super__.constructor.call(this, options, root);
    modelProps = this.getFacade().getModelProps(this.getModelName());
    belongsTo = this.constructor.belongsTo;
    subModelName = modelProps.getSubModelName(belongsTo);
    subIdName = modelProps.getIdPropByEntityProp(belongsTo);
    if (!modelProps.isEntity(belongsTo)) {
      throw new Error("\"belongsTo\" property: " + belongsTo + " is not an entity prop.");
    }
    hasSameSubModel = (function(_this) {
      return function() {
        var i, len, prop, ref;
        ref = modelProps.getEntityProps();
        for (i = 0, len = ref.length; i < len; i++) {
          prop = ref[i];
          if (prop !== belongsTo) {
            if (modelProps.getSubModelName(prop) === subModelName) {
              return true;
            }
          }
        }
        return false;
      };
    })(this)();
    this.foreignKeyName = subIdName;
    this.relClient = this.getRelatedClient({
      model: subModelName,
      foreignKey: hasSameSubModel ? this.foreignKeyName : null
    });
  }


  /**
  get client by entity
  if entity has foreign key, relClient is returned.
  
  @method getClientByEntity
  @protected
  @param {Entity|Object} entity
  @return {LoopbackClient} client
   */

  LoopbackRelationRepository.prototype.getClientByEntity = function(entity) {
    var foreignKey;
    foreignKey = entity != null ? entity[this.foreignKeyName] : void 0;
    return this.getClientByForeignKey(foreignKey);
  };


  /**
  get client by foreignKey
  
  @method getClientByForeignKey
  @protected
  @param {String} foreignKey
  @return {LoopbackClient} client
   */

  LoopbackRelationRepository.prototype.getClientByForeignKey = function(foreignKey) {
    if (foreignKey != null) {
      this.relClient.setId(foreignKey);
      return this.relClient;
    } else {
      return this.client;
    }
  };


  /**
  get client by query
  
  @method getClientByQuery
  @protected
  @param {Object} query
  @param {String} [query.foreignKey]
  @return {LoopbackClient} client
   */

  LoopbackRelationRepository.prototype.getClientByQuery = function(query) {
    var foreignKey, ref;
    if (query == null) {
      query = {};
    }
    if (query.hasOwnProperty('foreignKey')) {
      foreignKey = query.foreignKey;
    } else {
      foreignKey = (ref = query.where) != null ? ref[this.foreignKeyName] : void 0;
    }
    if (typeof foreignKey !== 'object') {
      return this.getClientByForeignKey(foreignKey);
    } else {
      return this.client;
    }
  };

  return LoopbackRelationRepository;

})(LoopbackRepository);

module.exports = LoopbackRelationRepository;
