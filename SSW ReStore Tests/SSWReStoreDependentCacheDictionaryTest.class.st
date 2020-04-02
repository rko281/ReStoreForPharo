"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreDependentCacheDictionaryTest,
	#superclass : #SSWReStoreRelatedCacheDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreDependentCacheDictionaryTest >> _testComponentExistenceOnDependency: component [

	"Private - collection is dependent at this level, so replaced/removed/cascade-deleted component should no longer exist"

	self assert: (component _dbProxyIn: reStore ifNone: [nil]) isNil.

	reStore simulateReconnect.
	self assert: ((component class storedInstancesIn: reStore) detect: [ :each | each name = component name] ifNone: [nil]) isNil
]

{ #category : #accessing }
SSWReStoreDependentCacheDictionaryTest >> componentDefinition [

	^(Dictionary of: #key -> GenericOwnedTest dependent)
]
