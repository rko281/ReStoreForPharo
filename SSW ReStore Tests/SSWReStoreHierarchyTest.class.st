"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreHierarchyTest,
	#superclass : #SSWReStoreTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> _testClassOfProxyOfIndirectInstanceOf: aClass [
	"Verify that, even when recovered via a second path, and without specifying the class as part of the retrieval,
	the class of the proxy of an object from a persistent hierarchy is set correctly (previously not the case for leaf classes)"

	self _testClassOfProxyOfInstanceOf: aClass
		recoveredBy: [:proxy | (reStore instancesOf: SuperPerson) asOrderedCollection collect: [:each | each firstName]].
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> _testClassOfProxyOfInstanceOf: aClass [

	self _testClassOfProxyOfInstanceOf: aClass recoveredBy: [ :proxy | proxy firstName]
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> _testClassOfProxyOfInstanceOf: aClass recoveredBy: aBlock [
	"Verify that, when recovered using aBlock after initially being an unrecovered proxy,
	the class of the proxy of an object from a persistent hierarchy is set correctly.
	Also verify that any mutable fields have been correctly copied and change-detection functions correctly."

	| owner proxy |
	"Just using MidPerson here for its reference to SuperPerson in its midFriend inst var"
	owner := MidPerson new firstName: 'owner'.
	owner midFriend: (aClass storedInstancesIn: reStore) first.
	owner storeIn: reStore.
	reStore simulateReconnect.

	"Read the owner; at this stage midFriend will just be an unrecovered proxy"
	owner := (MidPerson storedInstancesIn: reStore) detect: [:each | each firstName = 'owner'].
	self assert: owner midFriend isDBProxy.
	self assert: owner midFriend _proxiedObject isNil.
	self assert: owner midFriend _class equals: SuperPerson.	"at this stage - proxied object has not been read"

	"Recover it"
	aBlock value: owner midFriend.
	self deny: owner midFriend isDBProxy.
	self assert: owner midFriend class equals: aClass.
	proxy := owner midFriend _dbProxyIn: reStore.
	self assert: proxy _class equals: aClass.

	"Check that all declared mutable properties have been properly copied"
	aClass mutableAspects keysAndValuesDo: 
			[:i :sym |
			self deny: (proxy _proxiedObject perform: sym) == (proxy _copyObject perform: sym).
			self deny: ((owner midFriend perform: sym) isBitSet: i).	"Sanity check, bitmask initializes with 0"
			(owner midFriend perform: sym) bitSet: i].
	owner midFriend storeIn: reStore.
	reStore simulateReconnect.
	owner := (MidPerson storedInstancesIn: reStore) detect: [:each | each firstName = 'owner'].
	aClass mutableAspects
		keysAndValuesDo: [:i :sym | self assert: ((owner midFriend perform: sym) isBitSet: i)]
]

{ #category : #running }
SSWReStoreHierarchyTest >> addClassesTo: aReStore [

	aReStore
		addClassWithSubclasses: SuperPerson
]

{ #category : #running }
SSWReStoreHierarchyTest >> createTestData [

	(Array
		with: (SuperPerson new firstName: 'john')
		with: (MidPerson new firstName: 'dave'; middleName: 'davison'; surname: 'davidson')
		with: (SubPerson new firstName: 'mike'; middleName: 'michaelson'; surname: 'michaels'; age: 22)) storeAllIn: reStore.

	reStore simulateReconnect
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test01VerifySetUp [
	self assert: ((SuperPerson storedInstancesIn: reStore ) size = 3)
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test02Counts [

	| insts |

	insts := SuperPerson storedInstancesIn: reStore.
	self assert: (insts size = 3).

	insts := (SuperPerson storedInstancesIn: reStore ) withoutInheritance.
	self assert: (insts size = 1).

	insts := MidPerson storedInstancesIn: reStore.
	self assert: (insts size = 2).

	insts := (MidPerson storedInstancesIn: reStore) withoutInheritance.
	self assert: (insts size = 1).

	insts := SubPerson storedInstancesIn: reStore.
	self assert: (insts size = 1).

	insts := (SubPerson storedInstancesIn: reStore) withoutInheritance.
	self assert: (insts size = 1)
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test03Querying [

	"Querying for actual aspects"

	| persons midPersons subPersons |

	persons := SuperPerson storedInstancesIn: reStore.
	midPersons := MidPerson storedInstancesIn: reStore.
	subPersons := SubPerson storedInstancesIn: reStore.
	
	self assert: ((persons satisfying: [ :each | each firstName = 'john']) size = 1).
	self assert: ((midPersons satisfying: [ :each | each firstName = 'john']) size = 0).
	self assert: ((subPersons satisfying: [ :each | each firstName = 'john']) size = 0).
	
	self assert: ((persons satisfying: [ :each | each firstName = 'dave']) size = 1).
	self assert: ((persons withoutInheritance satisfying: [ :each | each firstName = 'dave']) size = 0).
	self assert: ((midPersons satisfying: [ :each | each firstName = 'dave']) size = 1).
	self assert: ((subPersons satisfying: [ :each | each firstName = 'dave']) size = 0).

	self assert: ((persons satisfying: [ :each | each firstName = 'mike']) size = 1).
	self assert: ((persons withoutInheritance satisfying: [ :each | each firstName = 'mike']) size = 0).
	self assert: ((midPersons satisfying: [ :each | each firstName = 'mike']) size = 1).
	self assert: ((midPersons withoutInheritance satisfying: [ :each | each firstName = 'mike']) size = 0).
	self assert: ((subPersons satisfying: [ :each | each firstName = 'mike']) size = 1).
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test04Classes [

	"Test proxies respond correctly to class both with and without cached proxy"

	| insts john dave mike |

	insts := SuperPerson storedInstancesIn: reStore.
	
	john := insts detect: [ :e | e firstName = 'john'].
	self assert: john isDBProxy.
	self assert: (john class = SuperPerson).
	john _forgetProxiedObject.
	self assert: (john class = SuperPerson).

	dave := insts detect: [ :e | e firstName = 'dave'].
	self assert: dave isDBProxy.
	self assert: (dave class = MidPerson).
	dave _forgetProxiedObject.
	self assert: (dave class = MidPerson).
	self assert: (dave middleName = 'davison').

	mike := insts detect: [ :e | e firstName = 'mike'].
	self assert: mike isDBProxy.
	self assert: (mike class = SubPerson).
	mike _forgetProxiedObject.
	self assert: (mike class = SubPerson).
	self assert: (mike middleName = 'michaelson').
	self assert: (mike age = 22)
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test05MidFirst [

	"Test a previously-erroring case where #first failed for mid and sub class collections (did not filter by class)"

	| midPersons |

	midPersons := MidPerson storedInstancesIn: reStore.
	self assert: ({MidPerson. SubPerson} includes: midPersons first class).
	self should: [(midPersons satisfying: [ :each | each firstName = 'john']) first] raise: Error
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> test06SubFirst [

	"Test a previously-erroring case where #first failed for mid and sub class collections (did not filter by class)"

	| subPersons |

	subPersons := SubPerson storedInstancesIn: reStore.

	self assert: (subPersons first class = SubPerson).
	self should: [(subPersons satisfying: [ :each | each firstName = 'john']) first] raise: Error
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testClassOfProxyOfIndirectMidInstance [

	self _testClassOfProxyOfIndirectInstanceOf: MidPerson
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testClassOfProxyOfIndirectSubInstance [

	self _testClassOfProxyOfIndirectInstanceOf: SubPerson
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testClassOfProxyOfIndirectSuperInstance [

	self _testClassOfProxyOfIndirectInstanceOf: SuperPerson
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testClassOfProxyOfMidInstance [

	self _testClassOfProxyOfInstanceOf: MidPerson
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testClassOfProxyOfSubInstance [

	self _testClassOfProxyOfInstanceOf: SubPerson
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testClassOfProxyOfSuperInstance [

	self _testClassOfProxyOfInstanceOf: SuperPerson
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testInheritanceStructureWithInheritance [

	reStore addClassWithSubclasses: AbstractA.

	self assert: (reStore tableForClass: AbstractA) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: AbstractB) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: ConcreteA) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: ConcreteB) name equals: (reStore sqlDialect transformClassName: #AbstractA)
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testInheritanceStructureWithoutInheritanceNonPersistentIntermediate [

	[AbstractA class methodDictionary at: #shouldSubclassesInheritPersistency put: (AbstractA class>>#shouldSubclassesInheritPersistencyFalse).
	AbstractA class flushMethodCache.

	reStore addClassWithSubclasses: AbstractA.
	self assert: (reStore tableForClass: AbstractA) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: AbstractB) name equals: (reStore sqlDialect transformClassName: #AbstractB).
	self assert: (reStore tableForClass: ConcreteA) name equals: (reStore sqlDialect transformClassName: #ConcreteA).
	self assert: (reStore tableForClass: ConcreteB) name equals: (reStore sqlDialect transformClassName: #ConcreteB)] ensure: 
		[AbstractA class methodDictionary removeKey: #shouldSubclassesInheritPersistency.
		AbstractA class flushMethodCache]
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testInheritanceStructureWithoutInheritancePersistentIntermediate [

	[AbstractA class methodDictionary at: #shouldSubclassesInheritPersistency put: (AbstractA class>>#shouldSubclassesInheritPersistencyFalse).
	AbstractB class methodDictionary at: #reStoreDefinition put: (AbstractB class>>#reStoreDefinitionEmpty).
	AbstractA class flushMethodCache.
	AbstractB class flushMethodCache.

	reStore addClassWithSubclasses: AbstractA.
	self assert: (reStore tableForClass: AbstractA) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: AbstractB) name equals: (reStore sqlDialect transformClassName: #AbstractB).
	self assert: (reStore tableForClass: ConcreteA) name equals: (reStore sqlDialect transformClassName: #AbstractB).
	self assert: (reStore tableForClass: ConcreteB) name equals: (reStore sqlDialect transformClassName: #AbstractB)] ensure: 
		[AbstractA class methodDictionary removeKey: #shouldSubclassesInheritPersistency.
		AbstractB  class methodDictionary removeKey: #reStoreDefinition.
		AbstractA class flushMethodCache.
		AbstractB class flushMethodCache]
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testInheritanceStructureWithoutInheritancePersistentIntermediateOldFormat [

	[AbstractA class methodDictionary at: #shouldSubclassesInheritPersistency put: (AbstractA class>>#shouldSubclassesInheritPersistencyFalse).
	AbstractB class methodDictionary at: #addClassDefinitionTo: put: (AbstractB class>>#addClassDefinitionToEmpty:).
	AbstractA class flushMethodCache.
	AbstractB class flushMethodCache.

	reStore addClassWithSubclasses: AbstractA.
	self assert: (reStore tableForClass: AbstractA) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: AbstractB) name equals: (reStore sqlDialect transformClassName: #AbstractB).
	self assert: (reStore tableForClass: ConcreteA) name equals: (reStore sqlDialect transformClassName: #AbstractB).
	self assert: (reStore tableForClass: ConcreteB) name equals: (reStore sqlDialect transformClassName: #AbstractB)] ensure: 
		[AbstractA class methodDictionary removeKey: #shouldSubclassesInheritPersistency.
		AbstractB  class methodDictionary removeKey: #addClassDefinitionTo:.
		AbstractA class flushMethodCache.
		AbstractB class flushMethodCache]
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testInheritanceStructureWithoutIntermediateInheritancePersistentIntermediate [

	[AbstractB class methodDictionary 
		at: #shouldSubclassesInheritPersistency put: (AbstractB class>>#shouldSubclassesInheritPersistencyFalse);
		at: #reStoreDefinition put: (AbstractB class>>#reStoreDefinitionEmpty).
	AbstractB class flushMethodCache.

	reStore addClassWithSubclasses: AbstractA.
	self assert: (reStore tableForClass: AbstractA) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: AbstractB) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: ConcreteA) name equals: (reStore sqlDialect transformClassName: #ConcreteA).
	self assert: (reStore tableForClass: ConcreteB) name equals: (reStore sqlDialect transformClassName: #ConcreteB)] ensure: 
		[AbstractB class methodDictionary
			removeKey: #shouldSubclassesInheritPersistency;
			removeKey: #reStoreDefinition.
		AbstractB class flushMethodCache]
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testInheritanceStructureWithoutIntermediateInheritancePersistentIntermediateOldFormat [

	[AbstractB class methodDictionary 
		at: #shouldSubclassesInheritPersistency put: (AbstractB class>>#shouldSubclassesInheritPersistencyFalse);
		at: #addClassDefinitionTo: put: (AbstractB class>>#addClassDefinitionToEmpty:).
	AbstractB class flushMethodCache.

	reStore addClassWithSubclasses: AbstractA.
	self assert: (reStore tableForClass: AbstractA) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: AbstractB) name equals: (reStore sqlDialect transformClassName: #AbstractA).
	self assert: (reStore tableForClass: ConcreteA) name equals: (reStore sqlDialect transformClassName: #ConcreteA).
	self assert: (reStore tableForClass: ConcreteB) name equals: (reStore sqlDialect transformClassName: #ConcreteB)] ensure: 
		[AbstractB class methodDictionary
			removeKey: #shouldSubclassesInheritPersistency;
			removeKey: #addClassDefinitionTo:.
		AbstractB class flushMethodCache]
]

{ #category : #'unit tests' }
SSWReStoreHierarchyTest >> testRetrievingIncompatibleClassRaisesError [
	| detailedID midID |
	midID := (reStore instancesOf: MidPerson) first _id.
	DetailedPerson1 new storeIn: reStore.
	detailedID := (reStore instancesOf: DetailedPerson1) first _id.
	reStore simulateReconnect.

	"Attempt to retrieve what is actually a DetailedPerson as if it were a MidPerson (siblings)"
	self should: [(reStore deferredObjectOfClass: MidPerson withID: detailedID) firstName] raise: Error description: 'Proxy for MidPerson retrieved a DetailedPerson1 from the database.'.
	"As above, but parent of the declared class"
	self should: [(reStore deferredObjectOfClass: SubPerson withID: midID) firstName] raise: Error description: 'Proxy for SubPerson retrieved a MidPerson from the database.'
]
