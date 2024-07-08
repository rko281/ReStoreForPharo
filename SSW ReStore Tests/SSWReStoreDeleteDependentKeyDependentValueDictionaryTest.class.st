Class {
	#name : 'SSWReStoreDeleteDependentKeyDependentValueDictionaryTest',
	#superclass : 'SSWReStoreDeleteDependentDictionaryTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'constants' }
SSWReStoreDeleteDependentKeyDependentValueDictionaryTest >> deleteQueriesCount [

	"How many queries to delete a collection?"
	^reStore sqlDialect supportsDeleteWithJoin
		ifTrue: [1 "single query for entries, keys and values"]
		ifFalse: [3 "one query for entries, one for keys, one for values"]
]

{ #category : 'constants' }
SSWReStoreDeleteDependentKeyDependentValueDictionaryTest >> ordersCollectionDefinition [

	^Dictionary of: (SimpleAddress dependent -> SimpleProductOrder dependent)
]

{ #category : 'unit tests' }
SSWReStoreDeleteDependentKeyDependentValueDictionaryTest >> testDeleteProxiedCollection [

	| keyTable allKeysCount customer2EntriesCount |

	keyTable := (reStore tableForClass: SimpleAddress) name.
	allKeysCount := (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first.
	customer2EntriesCount := (reStore executeSQL: 'select count(id) from <1s> where source_id = <2d>' << {((reStore tableForClass: SimplePerson) collectionAccessing: #orders) collectionTable name. customer2 _id}) results first contents first.

	super testDeleteProxiedCollection.

	"Verify the keys have been deleted"
	self assert: (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first equals: (allKeysCount - customer2EntriesCount)
]

{ #category : 'unit tests' }
SSWReStoreDeleteDependentKeyDependentValueDictionaryTest >> testDeleteUnproxiedCollection [

	| keyTable allKeysCount customer1EntriesCount |

	keyTable := (reStore tableForClass: SimpleAddress) name.
	allKeysCount := (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first.
	customer1EntriesCount := (reStore executeSQL: 'select count(id) from <1s> where source_id = <2d>' << {((reStore tableForClass: SimplePerson) collectionAccessing: #orders) collectionTable name. customer1 _id}) results first contents first.

	super testDeleteUnproxiedCollection.

	"Verify the keys have been deleted"
	self assert: (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first equals: (allKeysCount - customer1EntriesCount)
]
