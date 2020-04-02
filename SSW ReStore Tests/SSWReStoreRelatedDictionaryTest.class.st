"
ReStore
¬©2020 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreRelatedDictionaryTest,
	#superclass : #SSWReStoreGenericRelatedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #helpers }
SSWReStoreRelatedDictionaryTest >> addToCollection: aCollection [

	^aCollection at: self templateComponent put: self templateComponent
]

{ #category : #accessing }
SSWReStoreRelatedDictionaryTest >> componentDefinition [

	^(Dictionary of: GenericOwnedTest -> GenericOwnedTest related)
]

{ #category : #helpers }
SSWReStoreRelatedDictionaryTest >> remove: anObject fromCollection: aCollection [

	^aCollection removeKey: (aCollection keyAtValue: anObject)
]

{ #category : #public }
SSWReStoreRelatedDictionaryTest >> replaceInCollection: aCollection [

	| key old |

	key := aCollection keys anyOne.
	old := aCollection at: key.
	^old -> (aCollection at: key put: self templateComponent)
]

{ #category : #accessing }
SSWReStoreRelatedDictionaryTest >> templateCollection [

	^Dictionary new
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		at: self templateComponent put: self templateComponent;
		yourself
]
