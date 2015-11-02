var LoopbackRepository, LoopbackUserRepository, ModelDefinition;

LoopbackRepository = require('./loopback-repository');

LoopbackUserRepository = require('./loopback-user-repository');


/**
loopback model definition of one entity

@class ModelDefinition
@module base-domain-loopback
 */

ModelDefinition = (function() {
  function ModelDefinition(EntityModel, LoopbackRepository1, facade) {
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
    var Repo, prop, ref, relLbModelName, relModelProps, rels, typeInfo;
    rels = {};
    ref = this.getEntityProps();
    for (prop in ref) {
      typeInfo = ref[prop];
      relModelProps = this.facade.getModelProps(typeInfo.model);
      Repo = this.facade.require(typeInfo.model + '-repository');
      if (!(Repo.prototype instanceof LoopbackRepository)) {
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
    var rel;
    rel = {
      type: 'hasMany',
      model: relLbModelName,
      foreignKey: idPropName
    };
    return this.definition.relations[relLbModelName] = rel;
  };

  return ModelDefinition;

})();

module.exports = ModelDefinition;
