Class {
	#name : #SSWReStoreDeleteRelatedKeyDependentValueDictionaryTest,
	#superclass : #SSWReStoreDeleteDependentDictionaryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #constants }
SSWReStoreDeleteRelatedKeyDependentValueDictionaryTest >> ordersCollectionDefinition [

	^Dictionary of: (SimpleAddress related -> SimpleProductOrder dependent)
]

{ #category : #'unit tests' }
SSWReStoreDeleteRelatedKeyDependentValueDictionaryTest >> testDeleteProxiedCollection [

	| keyTable allKeysCount |

	keyTable := (reStore tableForClass: SimpleAddress) name.
	allKeysCount := (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first.

	super testDeleteProxiedCollection.

	"Verify the keys have not been deleted"
	self assert: (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first equals: allKeysCount
]

{ #category : #'unit tests' }
SSWReStoreDeleteRelatedKeyDependentValueDictionaryTest >> testDeleteUnproxiedCollection [

	| keyTable allKeysCount |

	keyTable := (reStore tableForClass: SimpleAddress) name.
	allKeysCount := (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first.

	super testDeleteUnproxiedCollection.

	"Verify the keys have been not deleted"
	self assert: (reStore executeSQL: 'select count(id_) from <1s>' << keyTable) results first contents first equals: allKeysCount
]
