Class {
	#name : #SSWReStoreDeleteDependentOwnedCollectionTest,
	#superclass : #SSWReStoreDeleteDependentCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreDeleteDependentOwnedCollectionTest class >> testSelectors [

	^self myTestSelectors
]

{ #category : #constants }
SSWReStoreDeleteDependentOwnedCollectionTest >> deleteQueriesCount [

	^1
]

{ #category : #constants }
SSWReStoreDeleteDependentOwnedCollectionTest >> ordersCollectionDefinition [

	"Owned collection"

	^(OrderedCollection of: SimpleProductOrder dependent owner: #customer)
]

{ #category : #tests }
SSWReStoreDeleteDependentOwnedCollectionTest >> testUnstoreCollectionElements [

	"Verify unstoring collection elements does not delete the owning customer (previous error case)"

	| id expectedCount |

	self deny: customer1 orders isEmpty.

	id := customer1 _id.
	expectedCount := (reStore instancesOf: SimpleProductOrder) size - customer1 orders size.

	"For dialects which do not supportsDeleteWithJoin this isn't supported"
	reStore sqlDialect supportsDeleteWithJoin
		ifTrue: [(reStore instancesOf: SimpleProductOrder) unstore: [ :each | each customer firstName = customer1 firstName]]
		ifFalse: [^self should: [(reStore instancesOf: SimpleProductOrder) unstore: [ :each | each customer firstName = customer1 firstName]] raise: Error].

	reStore simulateReconnect.
	customer1 := (reStore instancesOf: SimplePerson) detect: [ :each | each _id = id] ifNone: [nil].

	"Verify customer1 still exists"
	self assert: customer1 notNil.

	"Verify deletion has happened"
	self assert: customer1 orders isEmpty.	
	self assert: (reStore instancesOf: SimpleProductOrder) size equals: expectedCount
]
