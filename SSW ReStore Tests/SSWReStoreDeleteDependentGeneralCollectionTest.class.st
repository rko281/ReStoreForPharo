Class {
	#name : #SSWReStoreDeleteDependentGeneralCollectionTest,
	#superclass : #SSWReStoreDeleteDependentCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreDeleteDependentGeneralCollectionTest class >> testSelectors [

	^self myTestSelectors
]

{ #category : #constants }
SSWReStoreDeleteDependentGeneralCollectionTest >> deleteQueriesCount [

	"How many queries to delete a collection?"
	^reStore sqlDialect supportsDeleteWithJoin
		ifTrue: [1 "single query for entries and elements"]
		ifFalse: [2 "one query for entries, one for elements"]
]

{ #category : #constants }
SSWReStoreDeleteDependentGeneralCollectionTest >> ordersCollectionDefinition [

	"General (non-owned) collection"

	^(OrderedCollection of: SimpleProductOrder dependent)
]

{ #category : #'unit tests' }
SSWReStoreDeleteDependentGeneralCollectionTest >> testDeleteProxiedCollection [

	| collectionTable allEntriesCount customer2ID customer2EntriesCount |

	collectionTable := ((reStore tableForClass: SimplePerson) collectionAccessing: #orders) collectionTable name.
	allEntriesCount := (reStore executeSQL: 'select count(id) from <1s>' << collectionTable) results first contents first.
	customer2ID := customer2 _id.
	customer2EntriesCount := (reStore executeSQL: 'select count(id) from <1s> where source_id = <2p>' << {collectionTable. customer2ID}) results first contents first.

	super testDeleteProxiedCollection.

	"Verify the collection table entries have been deleted"
	self assert: (reStore executeSQL: 'select count(id) from <1s>' << collectionTable) results first contents first equals: (allEntriesCount - customer2EntriesCount).
	self assert: (reStore executeSQL: 'select count(id) from <1s> where source_id = <2p>' << {collectionTable. customer2ID}) results first contents first equals: 0
]

{ #category : #'unit tests' }
SSWReStoreDeleteDependentGeneralCollectionTest >> testDeleteUnproxiedCollection [

	| collectionTable allEntriesCount customer1ID customer1EntriesCount |

	collectionTable := ((reStore tableForClass: SimplePerson) collectionAccessing: #orders) collectionTable name.
	allEntriesCount := (reStore executeSQL: 'select count(id) from <1s>' << collectionTable) results first contents first.
	customer1ID := customer1 _id.
	customer1EntriesCount := (reStore executeSQL: 'select count(id) from <1s> where source_id = <2d>' << {collectionTable. customer1ID}) results first contents first.

	super testDeleteUnproxiedCollection.

	"Verify the collection table entries have been deleted"
	self assert: (reStore executeSQL: 'select count(id) from <1s>' << collectionTable) results first contents first equals: (allEntriesCount - customer1EntriesCount).
	self assert: (reStore executeSQL: 'select count(id) from <1s> where source_id = <2d>' << {collectionTable. customer1ID}) results first contents first equals: 0
]
