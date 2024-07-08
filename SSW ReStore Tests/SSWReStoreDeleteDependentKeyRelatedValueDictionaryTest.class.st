Class {
	#name : 'SSWReStoreDeleteDependentKeyRelatedValueDictionaryTest',
	#superclass : 'SSWReStoreDeleteRelatedDictionaryTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'constants' }
SSWReStoreDeleteDependentKeyRelatedValueDictionaryTest >> deleteQueriesCount [

	"How many queries to delete a collection?"
	^reStore sqlDialect supportsDeleteWithJoin
		ifTrue: [1 "single query for entries and keys"]
		ifFalse: [2 "one query for entries, one for keys"]
]

{ #category : 'constants' }
SSWReStoreDeleteDependentKeyRelatedValueDictionaryTest >> ordersCollectionDefinition [

	^Dictionary of: (SimpleAddress dependent -> SimpleProductOrder related)
]

{ #category : 'unit tests' }
SSWReStoreDeleteDependentKeyRelatedValueDictionaryTest >> testDeleteProxiedCollection [

	| keyTable allKeysCount customer2EntriesCount |

	keyTable := (reStore tableForClass: SimpleAddress) name.
	allKeysCount := (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first.
	customer2EntriesCount := (reStore executeSQL: 'select count(id) from <1s> where source_id = <2d>' << {((reStore tableForClass: SimplePerson) collectionAccessing: #orders) collectionTable name. customer2 _id}) results first contents first.

	super testDeleteProxiedCollection.

	"Verify the keys have been deleted"
	self assert: (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first equals: (allKeysCount - customer2EntriesCount)
]

{ #category : 'unit tests' }
SSWReStoreDeleteDependentKeyRelatedValueDictionaryTest >> testDeleteUnproxiedCollection [

	| keyTable allKeysCount customer1EntriesCount |

	keyTable := (reStore tableForClass: SimpleAddress) name.
	allKeysCount := (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first.
	customer1EntriesCount := (reStore executeSQL: 'select count(id) from <1s> where source_id = <2d>' << {((reStore tableForClass: SimplePerson) collectionAccessing: #orders) collectionTable name. customer1 _id}) results first contents first.

	super testDeleteUnproxiedCollection.

	"Verify the keys have been deleted"
	self assert: (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first equals: (allKeysCount - customer1EntriesCount)
]
