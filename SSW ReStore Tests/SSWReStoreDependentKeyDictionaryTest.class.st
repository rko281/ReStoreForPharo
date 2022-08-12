"
ReStore
©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreDependentKeyDictionaryTest,
	#superclass : #SSWReStoreRelatedKeyDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreDependentKeyDictionaryTest >> _testComponentExistenceOnDependency: value [

	"Private - collection is dependent at this level, so replaced/removed/cascade-deleted component should no longer exist"

	| component |

	"value is the removed key"
	component := value.

	self assert: (component _dbProxyIn: reStore ifNone: [nil]) isNil.

	reStore simulateReconnect.
	self assert: ((component class storedInstancesIn: reStore) detect: [ :each | each name = component name] ifNone: [nil]) isNil
]

{ #category : #accessing }
SSWReStoreDependentKeyDictionaryTest >> componentDefinition [

	^(Dictionary of: GenericOwnedTest dependent -> GenericOwnedTest)
]
