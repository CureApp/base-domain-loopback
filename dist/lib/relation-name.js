module.exports = function(params) {
  var foreignKey, keyThrough, model, through;
  if (params == null) {
    params = {};
  }
  model = params.model, foreignKey = params.foreignKey, keyThrough = params.keyThrough, through = params.through;
  if (through) {
    return model + '-via-' + keyThrough + '-at-' + through + '-with-' + foreignKey;
  } else if (foreignKey) {
    return model + '-with-' + foreignKey;
  } else {
    return model;
  }
};
