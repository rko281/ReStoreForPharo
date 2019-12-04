"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreNonRelatedDependentObjectTest,
	#superclass : #SSWReStoreNonRelatedObjectTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreNonRelatedDependentObjectTest >> _testComponentExistenceOnDependency [

	"component is dependent at this level, so should no longer exist"

	self assert: (component _dbProxyIn: reStore ifNone: [nil]) isNil.

	reStore simulateReconnect.
	self assert: ((reStore instancesOf: component class) detect: [ :each | each name = component name] ifNone: [nil]) isNil
]

{ #category : #accessing }
SSWReStoreNonRelatedDependentObjectTest >> componentDefinition [

	^GenericOwnedTest dependent unrelated
]

{ #category : #testing }
SSWReStoreNonRelatedDependentObjectTest >> testRefreshIfUpdatedRollbackRemovedComponentChange [

	"This test is not relevant to dependent relationships"
]
