Class {
	#name : #SSWReStoreAlternativeIDTest,
	#superclass : #SSWReStoreIDTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreAlternativeIDTest class >> isAbstract [

	^self == SSWReStoreAlternativeIDTest
]

{ #category : #running }
SSWReStoreAlternativeIDTest >> createTestData [
	
	(self testClass new name: 'test') storeIn: reStore.

	reStore simulateReconnect
]

{ #category : #testing }
SSWReStoreAlternativeIDTest >> shouldDestroyClasses [

	^true
]

{ #category : #'unit tests' }
SSWReStoreAlternativeIDTest >> testForeignIDCollection [

	| obj id owner id2 |

	GenericTest componentDefinition: (OrderedCollection of: self testClass).
	reStore addClass: GenericTest; synchronizeClass: GenericTest.

	obj := self testInstances detect: [:each | each name = 'test'].
	id := obj _id.
	
	owner := GenericTest new component: (OrderedCollection with: obj with: (self testClass new name: 'test2')).
	owner storeIn: reStore.
	id2 := owner component last _id.

	reStore simulateReconnect.
	owner := (GenericTest storedInstancesIn: reStore) first.
	self assert: (owner component collect: [ :each | each _id]) asArray equals: {id. id2}.
	self assert:  (self testInstances detect: [:each | each name = 'test']) identicalTo: owner component first.
	self assert:  (self testInstances detect: [:each | each name = 'test2']) identicalTo: owner component second.
	self assert: ((GenericTest storedInstancesIn: reStore) detect: [ :each | each component includes: owner component first]) identicalTo: owner.
	self assert: ((GenericTest storedInstancesIn: reStore) detect: [ :each | each component includes: owner component second]) identicalTo: owner.
]

{ #category : #'unit tests' }
SSWReStoreAlternativeIDTest >> testForeignIDObject [

	| obj id owner |

	GenericTest componentDefinition: self testClass.
	reStore addClass: GenericTest; synchronizeClass: GenericTest.

	obj := self testInstances detect: [:each | each name = 'test'].
	id := obj _id.
	
	owner := GenericTest new component: obj.
	owner storeIn: reStore.

	reStore simulateReconnect.
	owner := (GenericTest storedInstancesIn: reStore) first.
	self assert: owner component _id equals: id.
	self assert:  (self testInstances detect: [:each | each name = 'test']) identicalTo: owner component.
	self assert: ((GenericTest storedInstancesIn: reStore) detect: [ :each | each component = owner component]) identicalTo: owner.
	self assert: ((GenericTest storedInstancesIn: reStore) detect: [ :each | each component _id = id]) identicalTo: owner.
]

{ #category : #'unit tests' }
SSWReStoreAlternativeIDTest >> testForeignIDOwnedCollection [

	| obj id owner id2 |

	GenericTest componentDefinition: (OrderedCollection of: self testClass owner: #owner).
	reStore addClass: GenericTest; synchronizeClass: GenericTest.

	obj := self testInstances detect: [:each | each name = 'test'].
	id := obj _id.
	
	owner := GenericTest new component: (OrderedCollection with: obj with: (self testClass new name: 'test2')).
	owner storeIn: reStore.
	id2 := owner component last _id.

	reStore simulateReconnect.
	owner := (GenericTest storedInstancesIn: reStore) first.
	self assert: (owner component collect: [ :each | each _id]) asSet equals: {id. id2} asSet.
	self assert:  (owner component identityIncludes: (self testInstances detect: [:each | each name = 'test'])).
	self assert:  (owner component identityIncludes: (self testInstances detect: [:each | each name = 'test2'])).
	self assert: ((GenericTest storedInstancesIn: reStore) detect: [ :each | each component includes: owner component first]) identicalTo: owner.
	self assert: ((GenericTest storedInstancesIn: reStore) detect: [ :each | each component includes: owner component second]) identicalTo: owner.
]

{ #category : #'unit tests' }
SSWReStoreAlternativeIDTest >> testSourceIDCollection [

	"Ensure collections work with a source object with a non-Integer ID"

	GenericTest reStoreIDClass: GUID.
	[self testForeignIDCollection] ensure: [GenericTest reStoreIDClass: nil]
]

{ #category : #'unit tests' }
SSWReStoreAlternativeIDTest >> testSourceIDOwnedCollection [

	"Ensure owned collections work with a source object with a non-Integer ID"

	GenericTest reStoreIDClass: GUID.

	"Need to recreate the testClass table and test data to reflect the new ID Class of GenericTest, referenced via the testClass's owner field"
	[self addClassesTo: reStore.
	self destroyAllClasses.
	reStore synchronizeAllClasses.
	self createTestData.

	self testForeignIDOwnedCollection] ensure: [GenericTest reStoreIDClass: nil]
]
