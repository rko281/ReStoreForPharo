"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreDependentOwnedOrderedCollectionTest,
	#superclass : #SSWReStoreRelatedOwnedOrderedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreDependentOwnedOrderedCollectionTest >> _testComponentExistenceOnDependency: component [

	"collection is dependent at this level, so replaced/removed/cascade-deleted component should no longer exist"

	self assert: (component _dbProxyIn: reStore ifNone: [nil]) isNil.

	reStore simulateReconnect.
	self assert: ((reStore instancesOf: component class) detect: [ :each | each name = component name] ifNone: [nil]) isNil
]

{ #category : #accessing }
SSWReStoreDependentOwnedOrderedCollectionTest >> componentDefinition [

	^OrderedCollection of: GenericOwnedTest dependent owner: #owner
]
