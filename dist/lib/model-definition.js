var LoopbackUserRepository, ModelDefinition;

LoopbackUserRepository = require('./loopback-user-repository');


/**
loopback model definition of one entity

@class ModelDefinition
@module base-domain-loopback
 */

ModelDefinition = (function() {
  function ModelDefinition(EntityModel, LoopbackRepository, facade) {
    this.EntityModel = EntityModel;
    this.LoopbackRepository = LoopbackRepository;
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
  }


  /**
  get model name
  
  @method getName
  @public
  @return {String} modelName
   */

  ModelDefinition.prototype.getName = function() {
    return this.EntityModel.getName();
  };


  /**
  get plural model name: the same as getName() for simplicity
  
  @method getPluralName
  @private
  @return {String} modelName
   */

  ModelDefinition.prototype.getPluralName = function() {
    return this.EntityModel.getName();
  };


  /**
  get "base" setting.
  "User" or "PersistedModel"
  
  @method getName
  @public
  @return {String} modelName
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
    var prop, ref, rels, typeInfo;
    rels = {};
    ref = this.getEntityProps();
    for (prop in ref) {
      typeInfo = ref[prop];
      rels[prop] = {
        type: 'belongsTo',
        model: typeInfo.model,
        foreignKey: typeInfo.idPropName
      };
    }
    return rels;
  };


  /**
  set "hasMany" relations
  
  @method setHasManyRelation
  @param {String} relModel
  @param {String} idPropName foreignKey
   */

  ModelDefinition.prototype.setHasManyRelation = function(relModel, idPropName) {
    var rel;
    rel = {
      type: 'hasMany',
      model: relModel,
      foreignKey: idPropName
    };
    return this.definition.relations[relModel] = rel;
  };

  return ModelDefinition;

})();

module.exports = ModelDefinition;
