
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

            expect(def.definition).to.be.an 'object'

    describe 'definition', ->
        before ->
            @defObj = new ModelDefinition(@Child, @ChildRepository, @domain).definition

        it 'contains aclType, the same as repository\'s aclType', ->
            expect(@defObj).to.have.property 'aclType', 'public-read'

        it 'contains name, the same as LoopbackRepository.getLbModelName()', ->
            expect(@defObj).to.have.property 'name', 'cld'

        it 'contains plural name, the same as "name"', ->
            expect(@defObj).to.have.property 'plural', 'cld'

        it 'contains base = PersistedModel', ->
            expect(@defObj).to.have.property 'base', 'PersistedModel'

        it 'contains idInjection = true', ->
            expect(@defObj).to.have.property 'idInjection', true

        it 'contains properties', ->
            expect(@defObj).to.have.property 'properties'

        it 'contains validations', ->
            expect(@defObj).to.have.property 'validations'

        it 'contains [belongsTo] relations', ->
            expect(@defObj).to.have.property 'relations'
            expect(@defObj.relations).to.have.property 'pnt'
            expect(@defObj.relations.pnt).to.have.property 'type', 'belongsTo'


    describe 'getName', ->

        it 'returns name of the entity model', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            expect(def.getName()).to.equal 'cld'


    describe 'getPluralName', ->

        it 'returns plural name of the entity model', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            expect(def.getPluralName()).to.equal 'cld'

    describe 'getBase', ->

        it 'returns "PersistedModel" if entity model isnt child class of LoopbackUserRepository', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            expect(def.getBase()).to.equal 'PersistedModel'


        it 'returns "User" if entity model isnt child class of LoopbackUserRepository', ->
            def = new ModelDefinition(@Member, @MemberRepository, @domain)
            expect(def.getBase()).to.equal 'User'

    describe 'export', ->

        it 'returns definition object', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            expect(def.export()).to.equal def.definition


    describe 'getEntityProps', ->

        it 'returns typeInfo of the sub-entities', ->
            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            expect(def.getEntityProps()).to.have.property 'pnt'
            expect(def.getEntityProps().pnt).to.have.property 'model', 'parent'


    describe 'getBelongsToRelations', ->

        it 'returns "belongsTo" relations', ->

            rels = new ModelDefinition(@Child, @ChildRepository, @domain).getBelongsToRelations()

            expect(rels).to.have.property 'pnt'
            expect(rels.pnt).to.have.property 'type', 'belongsTo'
            expect(rels.pnt).to.have.property 'model', 'loopback-parent'
            expect(rels.pnt).to.have.property 'foreignKey', 'parentId'


    describe 'setHasManyRelation', ->

        it 'set "hasMany" relations to definition object', ->

            def = new ModelDefinition(@Child, @ChildRepository, @domain)
            def.setHasManyRelation('xxx', 'xxxId')

            rels = def.definition.relations

            expect(rels).to.have.property 'xxx'
            expect(rels.xxx).to.have.property 'type', 'hasMany'
            expect(rels.xxx).to.have.property 'model', 'xxx'
            expect(rels.xxx).to.have.property 'foreignKey', 'xxxId'



module.exports = ModelDefinition
