"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreDependentObjectTest,
	#superclass : #SSWReStoreRelatedObjectTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreDependentObjectTest >> _testComponentExistenceOnDependency [

	"component is dependent at this level, so should no longer exist"

	self assert: (component _dbProxyIn: reStore ifNone: [nil]) isNil.

	reStore simulateReconnect.
	self assert: ((reStore instancesOf: component class) detect: [ :each | each name = component name] ifNone: [nil]) isNil
]

{ #category : #accessing }
SSWReStoreDependentObjectTest >> componentDefinition [

	^GenericOwnedTest dependent
]

{ #category : #testing }
SSWReStoreDependentObjectTest >> testRefreshIfUpdatedRollbackRemovedComponentChange [

	"This test is not relevant to dependent relationships"
]
