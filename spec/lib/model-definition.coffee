
ModelDefinition = require '../../src/lib/model-definition'

domain = require('../create-facade').create()
Facade = domain.constructor

class Child extends Facade.Entity
    @belongsTo: 'pnt'
    @properties: pnt: @TYPES.MODEL 'parent'

class Parent extends Facade.Entity
class Member extends Facade.Entity

class ChildRepository  extends Facade.LoopbackRelationRepository
    @aclType: 'public-read'

class ParentRepository extends Facade.LoopbackRepository

class NonEntity extends Facade.BaseModel
class NonLoopback extends Facade.Entity
class NonLoopbackRepository extends Facade.BaseRepository
class MemberRepository extends Facade.LoopbackUserRepository

domain.addClass('child', Child)
domain.addClass('parent', Parent)
domain.addClass('member', Member)
domain.addClass('child-repository', ChildRepository)
domain.addClass('parent-repository', ParentRepository)
domain.addClass('non-entity', NonEntity)
domain.addClass('non-loopback', NonLoopback)
domain.addClass('non-loopback-repository', NonLoopbackRepository)
domain.addClass('member-repository', MemberRepository)


describe 'ModelDefinition', ->

    before ->
        @Child = domain.getModel('child')
        @ChildRepository = domain.getRepository('child')
        @Member = domain.getModel('member')
        @MemberRepository = domain.getRepository('member')

    describe 'constructor', ->

        it 'contains definition', ->
            def = new ModelDefinition(@Child, @ChildRepository)

            expect(def.definition).to.be.an 'object'

    describe 'definition', ->
        before ->
            @defObj = new ModelDefinition(@Child, @ChildRepository).definition

        it 'contains aclType, the same as repository\'s aclType', ->
            expect(@defObj).to.have.property 'aclType', 'public-read'

        it 'contains name, the same as Entity\'s name', ->
            expect(@defObj).to.have.property 'name', @Child.getName()

        it 'contains plural name, the same as Entity\'s name', ->
            expect(@defObj).to.have.property 'plural', @Child.getName()

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
            def = new ModelDefinition(@Child, @ChildRepository)
            expect(def.getName()).to.equal 'child'


    describe 'getPluralName', ->

        it 'returns plural name of the entity model', ->
            def = new ModelDefinition(@Child, @ChildRepository)
            expect(def.getPluralName()).to.equal 'child'

    describe 'getBase', ->

        it 'returns "PersistedModel" if entity model isnt child class of LoopbackUserRepository', ->
            def = new ModelDefinition(@Child, @ChildRepository)
            expect(def.getBase()).to.equal 'PersistedModel'


        it 'returns "User" if entity model isnt child class of LoopbackUserRepository', ->
            def = new ModelDefinition(@Member, @MemberRepository)
            expect(def.getBase()).to.equal 'User'

    describe 'export', ->

        it 'returns definition object', ->
            def = new ModelDefinition(@Child, @ChildRepository)
            expect(def.export()).to.equal def.definition


    describe 'getEntityPropInfo', ->

        it 'returns typeInfo of the sub-entities', ->
            def = new ModelDefinition(@Child, @ChildRepository)
            expect(def.getEntityPropInfo()).to.have.property 'pnt'
            expect(def.getEntityPropInfo().pnt).to.have.property 'model', 'parent'


    describe 'getBelongsToRelations', ->

        it 'returns "belongsTo" relations', ->

            rels = new ModelDefinition(@Child, @ChildRepository).getBelongsToRelations()

            expect(rels).to.have.property 'pnt'
            expect(rels.pnt).to.have.property 'type', 'belongsTo'
            expect(rels.pnt).to.have.property 'model', 'parent'
            expect(rels.pnt).to.have.property 'foreignKey', 'parentId'


    describe 'setHasManyRelation', ->

        it 'set "hasMany" relations to definition object', ->

            def = new ModelDefinition(@Child, @ChildRepository)
            def.setHasManyRelation('xxx')

            rels = def.definition.relations

            expect(rels).to.have.property 'xxx'
            expect(rels.xxx).to.have.property 'type', 'hasMany'
            expect(rels.xxx).to.have.property 'model', 'xxx'
            expect(rels.xxx).to.have.property 'foreignKey', ''



module.exports = ModelDefinition
