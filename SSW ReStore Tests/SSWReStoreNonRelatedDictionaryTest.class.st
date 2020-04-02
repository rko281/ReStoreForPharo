"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreNonRelatedDictionaryTest,
	#superclass : #SSWReStoreGenericNonRelatedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreNonRelatedDictionaryTest >> addToCollection: aCollection [

	^aCollection at: self templateComponent put: self templateComponent
]

{ #category : #accessing }
SSWReStoreNonRelatedDictionaryTest >> componentDefinition [

	^(Dictionary of: GenericOwnedTest -> GenericOwnedTest)
]

{ #category : #helpers }
SSWReStoreNonRelatedDictionaryTest >> remove: anObject fromCollection: aCollection [

	^aCollection removeKey: (aCollection keyAtValue: anObject)
]

{ #category : #helpers }
SSWReStoreNonRelatedDictionaryTest >> removeFromCollection: aCollection [

	^aCollection removeKey: collection keys anyOne
]

{ #category : #public }
SSWReStoreNonRelatedDictionaryTest >> replaceInCollection: aCollection [

	| key old |

	key := aCollection keys anyOne.
	old := aCollection at: key.
	^old -> (aCollection at: key put: self templateComponent)
]

{ #category : #accessing }
SSWReStoreNonRelatedDictionaryTest >> templateCollection [

	^Dictionary new
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		yourself
]
