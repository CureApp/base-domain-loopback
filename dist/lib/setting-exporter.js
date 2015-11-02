var LoopbackRepository, ModelDefinition, SettingExporter, debug, fs;

debug = require('debug')('base-domain-loopback:setting-exporter');

fs = require('fs');

LoopbackRepository = require('./loopback-repository');

ModelDefinition = require('./model-definition');


/**
export model info into loopback-with-admin's format
only available in Node.js

@class SettingExporter
@module base-domain-loopback
 */

SettingExporter = (function() {
  function SettingExporter(facade) {
    this.facade = facade;
  }


  /**
  Create ModelDefinitions
  
  1. load all the entities
  2. check each entity's repository is LoopbackRepository
  3. create ModelDefinition
  4. add "hasMany" Relations
  5. return object
  
  @method export
  @public
  @return {Object}
   */

  SettingExporter.prototype["export"] = function() {
    var EntityModel, EntityRepository, definition, definitions, e, i, lbModelName, len, modelName, name, ref;
    definitions = {};
    ref = this.getAllEntityModels();
    for (i = 0, len = ref.length; i < len; i++) {
      EntityModel = ref[i];
      modelName = EntityModel.getName();
      try {
        EntityRepository = this.facade.require(modelName + '-repository');
        if (!(EntityRepository.prototype instanceof LoopbackRepository)) {
          continue;
        }
      } catch (_error) {
        e = _error;
        debug('Error in reading repository of %s', modelName);
        debug(e.message);
        debug(e.stack);
        continue;
      }
      lbModelName = EntityRepository.getLbModelName();
      definitions[lbModelName] = new ModelDefinition(EntityModel, EntityRepository, this.facade);
    }
    this.setHasManyRelations(definitions);
    for (name in definitions) {
      definition = definitions[name];
      definitions[name] = definition["export"]();
    }
    return definitions;
  };


  /**
  set "hasMany" relations
  
  @private
   */

  SettingExporter.prototype.setHasManyRelations = function(definitions) {
    var definition, lbModelName, prop, relModelDefinition, relModelName, results, typeInfo;
    results = [];
    for (lbModelName in definitions) {
      definition = definitions[lbModelName];
      results.push((function() {
        var ref, results1;
        ref = definition.getEntityProps();
        results1 = [];
        for (prop in ref) {
          typeInfo = ref[prop];
          relModelName = typeInfo.model;
          relModelDefinition = definitions[relModelName];
          results1.push(relModelDefinition != null ? relModelDefinition.setHasManyRelation(lbModelName, typeInfo.idPropName) : void 0);
        }
        return results1;
      })());
    }
    return results;
  };


  /**
  get all entity models registered in domain facade
  
  @private
   */

  SettingExporter.prototype.getAllEntityModels = function() {
    var klass, name;
    this.loadAll();
    return (function() {
      var ref, results;
      ref = this.facade.classes;
      results = [];
      for (name in ref) {
        klass = ref[name];
        if (klass.isEntity) {
          results.push(klass);
        }
      }
      return results;
    }).call(this);
  };


  /**
  load all models in directory
  
  @private
   */

  SettingExporter.prototype.loadAll = function() {
    var domainFiles, e, ext, filename, i, len, name, ref, results;
    if (!fs.existsSync(this.facade.dirname)) {
      return;
    }
    domainFiles = fs.readdirSync(this.facade.dirname);
    results = [];
    for (i = 0, len = domainFiles.length; i < len; i++) {
      filename = domainFiles[i];
      try {
        ref = filename.split('.'), name = ref[0], ext = ref[1];
        if (ext !== 'coffee' && ext !== 'js') {
          continue;
        }
        results.push(this.facade.require(name));
      } catch (_error) {
        e = _error;
        debug('Error in reading file: %s', filename);
        debug(e.message);
        results.push(debug(e.stack));
      }
    }
    return results;
  };

  return SettingExporter;

})();

module.exports = SettingExporter;
