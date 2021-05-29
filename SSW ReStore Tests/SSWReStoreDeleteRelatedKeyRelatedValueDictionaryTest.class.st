Class {
	#name : #SSWReStoreDeleteRelatedKeyRelatedValueDictionaryTest,
	#superclass : #SSWReStoreDeleteRelatedDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #constants }
SSWReStoreDeleteRelatedKeyRelatedValueDictionaryTest >> ordersCollectionDefinition [

	^Dictionary of: (SimpleAddress related -> SimpleProductOrder related)
]

{ #category : #'unit tests' }
SSWReStoreDeleteRelatedKeyRelatedValueDictionaryTest >> testDeleteProxiedCollection [

	| keyTable allKeysCount |

	keyTable := (reStore tableForClass: SimpleAddress) name.
	allKeysCount := (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first.

	super testDeleteProxiedCollection.

	"Verify the keys have not been deleted"
	self assert: (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first equals: allKeysCount
]

{ #category : #'unit tests' }
SSWReStoreDeleteRelatedKeyRelatedValueDictionaryTest >> testDeleteUnproxiedCollection [

	| keyTable allKeysCount |

	keyTable := (reStore tableForClass: SimpleAddress) name.
	allKeysCount := (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first.

	super testDeleteUnproxiedCollection.

	"Verify the keys have not been deleted"
	self assert: (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first equals: allKeysCount
]
