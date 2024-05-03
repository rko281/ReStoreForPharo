Class {
	#name : #SSWReStoreBaseDictionaryTest,
	#superclass : #SSWReStoreBaseCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreBaseDictionaryTest >> addToCollection: anObject at: anInteger [

	testObject component at: anInteger put: anObject.

	^anInteger
]

{ #category : #accessing }
SSWReStoreBaseDictionaryTest >> collectionClass [

	^Dictionary
]

{ #category : #accessing }
SSWReStoreBaseDictionaryTest >> componentDefinition [

	^Dictionary of: Integer -> (String maxSize: 64)
]

{ #category : #helpers }
SSWReStoreBaseDictionaryTest >> removeFromCollection: anObject [

	^self removeFromCollection: anObject at: (testObject component keyAtEqualValue: anObject ifAbsent: [])
]

{ #category : #helpers }
SSWReStoreBaseDictionaryTest >> removeFromCollection: anObject at: aKey [

	testObject component removeKey: aKey.
	^aKey
]
