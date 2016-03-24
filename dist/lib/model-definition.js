'use strict';
var LoopbackRepository, LoopbackUserRepository, ModelDefinition, relationName;

LoopbackRepository = require('./loopback-repository');

LoopbackUserRepository = require('./loopback-user-repository');

relationName = require('./relation-name');


/**
loopback model definition of one entity

@class ModelDefinition
@module base-domain-loopback
 */

ModelDefinition = (function() {
  function ModelDefinition(EntityModel, LoopbackRepository1, facade) {
    var k, ref, ref1, v;
    this.EntityModel = EntityModel;
    this.LoopbackRepository = LoopbackRepository1;
    this.facade = facade;
    this.definition = {
      aclType: this.LoopbackRepository.aclType,
      name: this.getName(),
      plural: this.getPluralName(),
      base: this.getBase(),
      idInjection: true,
      properties: {},
      validations: [],
      relations: this.getBelongsToRelations()
    };
    ref1 = (ref = this.LoopbackRepository.lbDefinitions) != null ? ref : {};
    for (k in ref1) {
      v = ref1[k];
      this.definition[k] = v;
    }
  }


  /**
  get model name
  
  @method getName
  @public
  @return {String} lbModelName
   */

  ModelDefinition.prototype.getName = function() {
    return this.LoopbackRepository.getLbModelName();
  };


  /**
  get plural model name: the same as getName() for simplicity
  
  @method getPluralName
  @private
  @return {String} lbModelName
   */

  ModelDefinition.prototype.getPluralName = function() {
    return this.LoopbackRepository.getLbModelName();
  };


  /**
  get "base" setting.
  "User" or "PersistedModel"
  
  @method getName
  @public
  @return {String}
   */

  ModelDefinition.prototype.getBase = function() {
    if (this.LoopbackRepository.prototype instanceof LoopbackUserRepository) {
      return 'User';
    } else {
      return 'PersistedModel';
    }
  };


  /**
  Returns the definition
  
  @method export
  @public
  @return {Object} definition
   */

  ModelDefinition.prototype["export"] = function() {
    return this.definition;
  };


  /**
  get props info of sub-entities
  
  @method getEntityProps
  @return {Object(TypeInfo)}
   */

  ModelDefinition.prototype.getEntityProps = function() {
    var i, info, len, modelProps, prop, ref;
    info = {};
    modelProps = this.facade.getModelProps(this.EntityModel.getName());
    ref = modelProps.entities;
    for (i = 0, len = ref.length; i < len; i++) {
      prop = ref[i];
      info[prop] = modelProps.dic[prop];
    }
    return info;
  };


  /**
  get "belongsTo" relations
  
  @private
   */

  ModelDefinition.prototype.getBelongsToRelations = function() {
    var Repo, e, error, prop, ref, relLbModelName, relModelProps, rels, typeInfo;
    rels = {};
    ref = this.getEntityProps();
    for (prop in ref) {
      typeInfo = ref[prop];
      relModelProps = this.facade.getModelProps(typeInfo.model);
      try {
        Repo = this.facade.require(typeInfo.model + '-repository');
        if (!(Repo.prototype instanceof LoopbackRepository)) {
          continue;
        }
      } catch (error) {
        e = error;
        continue;
      }
      relLbModelName = Repo.getLbModelName();
      rels[prop] = {
        type: 'belongsTo',
        model: relLbModelName,
        foreignKey: typeInfo.idPropName
      };
    }
    return rels;
  };


  /**
  set "hasMany" relations
  
  @method setHasManyRelation
  @param {String} relLbModelName
  @param {String} idPropName foreignKey
   */

  ModelDefinition.prototype.setHasManyRelation = function(relLbModelName, idPropName) {
    var rel, relName;
    rel = {
      type: 'hasMany',
      model: relLbModelName,
      foreignKey: idPropName
    };
    relName = relationName(rel);
    this.definition.relations[relName] = rel;
    return this.definition.relations[relLbModelName] = rel;
  };


  /**
  set "hasManyThrough" relations
  
  @method setHasManyThroughRelation
  @param {String} relLbModelName
  @param {String} idPropName foreignKey
   */

  ModelDefinition.prototype.setHasManyThroughRelation = function(params) {
    var foreignKey, keyThrough, model, relName, through;
    if (params == null) {
      params = {};
    }
    relName = relationName(params);
    model = params.model, foreignKey = params.foreignKey, keyThrough = params.keyThrough, through = params.through;
    return this.definition.relations[relName] = {
      type: 'hasMany',
      model: model,
      foreignKey: foreignKey,
      keyThrough: keyThrough,
      through: through
    };
  };

  ModelDefinition.prototype.addCustomRelations = function() {
    var params, ref, relName, results;
    if (this.LoopbackRepository.relations == null) {
      return;
    }
    ref = this.LoopbackRepository.relations;
    results = [];
    for (relName in ref) {
      params = ref[relName];
      results.push(this.definition.relations[relName] = params);
    }
    return results;
  };

  return ModelDefinition;

})();

module.exports = ModelDefinition;
