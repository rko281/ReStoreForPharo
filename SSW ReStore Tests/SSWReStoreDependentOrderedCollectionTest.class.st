"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreDependentOrderedCollectionTest,
	#superclass : #SSWReStoreRelatedOrderedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreDependentOrderedCollectionTest >> _testComponentExistenceOnDependency: component [

	"Private - collection is dependent at this level, so replaced/removed/cascade-deleted component should no longer exist"

	self assert: (component _dbProxyIn: reStore ifNone: [nil]) isNil.

	reStore simulateReconnect.
	self assert: ((component class storedInstancesIn: reStore) detect: [ :each | each name = component name] ifNone: [nil]) isNil
]

{ #category : #accessing }
SSWReStoreDependentOrderedCollectionTest >> componentDefinition [

	^OrderedCollection of: GenericOwnedTest dependent
]
