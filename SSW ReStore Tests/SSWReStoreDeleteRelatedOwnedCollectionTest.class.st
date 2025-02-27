Class {
	#name : 'SSWReStoreDeleteRelatedOwnedCollectionTest',
	#superclass : 'SSWReStoreDeleteRelatedCollectionTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreDeleteRelatedOwnedCollectionTest class >> testSelectors [

	^self myTestSelectors
]

{ #category : 'constants' }
SSWReStoreDeleteRelatedOwnedCollectionTest >> deleteCustomer1QueriesCount [

	"To respect the change detection mechanism, the removal of elements from an owned collection (which involves setting the owner link to nil) must be done to each element individually"
	^1  + 11 "customer + 11 collection entries"
]

{ #category : 'constants' }
SSWReStoreDeleteRelatedOwnedCollectionTest >> deleteCustomer2QueriesCount [

	"To respect the change detection mechanism, the removal of elements from an owned collection (which involves setting the owner link to nil) must be done to each element individually"
	^1 + 10 "customer + 10 collection elements"
]

{ #category : 'constants' }
SSWReStoreDeleteRelatedOwnedCollectionTest >> deleteQueriesCount [

	"Not used here; just to satisfy subclassResponsibility"
	^self shouldNotImplement
]

{ #category : 'constants' }
SSWReStoreDeleteRelatedOwnedCollectionTest >> ordersCollectionDefinition [

	"Owned collection"

	^(OrderedCollection of: SimpleProductOrder related owner: #customer)
]

{ #category : 'unit tests' }
SSWReStoreDeleteRelatedOwnedCollectionTest >> testDeleteProxiedCollection [

	| customer2Orders |

	customer2Orders := (SimpleProductOrder storedInstancesIn: reStore) select: [ :each | each customer = customer2].
	self assert: (customer2Orders allSatisfy: [ :each | each customer = customer2]).

	super testDeleteProxiedCollection.

	"Verify the backpointers are nil"
	self assert: (customer2Orders allSatisfy: [ :each | each customer isNil])
]

{ #category : 'unit tests' }
SSWReStoreDeleteRelatedOwnedCollectionTest >> testDeleteUnproxiedCollection [

	| customer1Orders |

	customer1Orders := (SimpleProductOrder storedInstancesIn: reStore) select: [ :each | each customer = customer1].
	self assert: (customer1Orders allSatisfy: [ :each | each customer = customer1]).

	super testDeleteUnproxiedCollection.

	"Verify the backpointers are nil"
	self assert: (customer1Orders allSatisfy: [ :each | each customer isNil])
]

{ #category : 'unit tests' }
SSWReStoreDeleteRelatedOwnedCollectionTest >> testUnstoreCollectionElements [

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
