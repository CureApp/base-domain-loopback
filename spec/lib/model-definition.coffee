
ModelDefinition = require '../../src/lib/model-definition'
Facade = require '../base-domain-loopback'

{ Entity, LoopbackRepository, LoopbackUserRepository,
LoopbackRelationRepository, BaseModel, BaseRepository } = Facade

describe 'ModelDefinition', ->

    beforeEach ->

        @domain = require('../create-facade').create()

        class Child extends Entity
            @belongsTo: 'pnt'
            @properties: pnt: @TYPES.MODEL 'parent'

        class Parent extends Entity
        class Member extends Entity

        class ChildRepository  extends LoopbackRelationRepository
            @modelName: 'child'
            @lbModelName: 'cld'
            @aclType: 'public-read'

        class ParentRepository extends LoopbackRepository
            @modelName: 'parent'
            @lbModelName: 'loopback-parent'

        class NonEntity extends BaseModel
        class NonLoopback extends Entity
        class NonLoopbackRepository extends BaseRepository
        class MemberRepository extends LoopbackUserRepository

        @domain.addClass('child', Child)
        @domain.addClass('parent', Parent)
        @domain.addClass('member', Member)
        @domain.addClass('child-repository', ChildRepository)
        @domain.addClass('parent-repository', ParentRepository)
        @domain.addClass('non-entity', NonEntity)
        @domain.addClass('non-loopback', NonLoopback)
        @domain.addClass('non-loopback-repository', NonLoopbackRepository)
        @domain.addClass('member-repository', MemberRepository)

        @Child = Child
        @ChildRepository = ChildRepository
        @Member = Member
        @MemberRepository = MemberRepository


    describe 'constructor', ->

        it 'contains definition', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)

            assert typeof def.definition is 'object'

    describe 'definition', ->
        before ->
            @defObj = new ModelDefinition(@Child, @ChildRepository, @domain).definition

        it 'contains aclType, the same as repository\'s aclType', ->
            assert @defObj.aclType is 'public-read'

        it 'contains name, the same as LoopbackRepository.getLbModelName()', ->
            assert @defObj.name is 'cld'

        it 'contains plural name, the same as "name"', ->
            assert @defObj.plural is 'cld'

        it 'contains base = PersistedModel', ->
            assert @defObj.base is 'PersistedModel'

        it 'contains idInjection = true', ->
            assert @defObj.idInjection

        it 'contains properties', ->
            assert @defObj.properties?

        it 'contains validations', ->
            assert @defObj.validations?

        it 'contains [belongsTo] relations', ->
            assert @defObj.relations?
            assert @defObj.relations.pnt?
            assert @defObj.relations.pnt.type is 'belongsTo'


    describe 'getName', ->

        it 'returns name of the entity model', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            assert def.getName() is 'cld'


    describe 'getPluralName', ->

        it 'returns plural name of the entity model', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            assert def.getPluralName() is 'cld'

    describe 'getBase', ->

        it 'returns "PersistedModel" if entity model isnt child class of LoopbackUserRepository', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            assert def.getBase() is 'PersistedModel'


        it 'returns "User" if entity model isnt child class of LoopbackUserRepository', ->
            def = new ModelDefinition(@Member, @MemberRepository, @domain)
            assert def.getBase() is 'User'

    describe 'export', ->

        it 'returns definition object', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            assert def.export() is def.definition


    describe 'getEntityProps', ->

        it 'returns typeInfo of the sub-entities', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            assert def.getEntityProps().pnt?
            assert def.getEntityProps().pnt.model is 'parent'


    describe 'getBelongsToRelations', ->

        it 'returns "belongsTo" relations', ->

            rels = new ModelDefinition(@Child, @ChildRepository, @domain).getBelongsToRelations()

            assert rels.pnt?
            assert rels.pnt.type is 'belongsTo'
            assert rels.pnt.model is 'loopback-parent'
            assert rels.pnt.foreignKey is 'parentId'


    describe 'setHasManyRelation', ->

        it 'set "hasMany" relations to definition object', ->

            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            def.setHasManyRelation('xxx', 'xxxId')

            rels = def.definition.relations

            assert rels.xxx?
            assert rels.xxx.type is 'hasMany'
            assert rels.xxx.model is 'xxx'
            assert rels.xxx.foreignKey is 'xxxId'



module.exports = ModelDefinition
