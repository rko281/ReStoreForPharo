"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreNonRelatedOwnedOrderedCollectionTest,
	#superclass : #SSWReStoreGenericNonRelatedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreNonRelatedOwnedOrderedCollectionTest >> componentDefinition [

	^OrderedCollection of: GenericOwnedTest owner: #owner
]

{ #category : #public }
SSWReStoreNonRelatedOwnedOrderedCollectionTest >> replaceInCollection: aCollection [

	^(aCollection at: aCollection size) -> (aCollection at: aCollection size put: self templateComponent)
]

{ #category : #accessing }
SSWReStoreNonRelatedOwnedOrderedCollectionTest >> templateCollection [

	^OrderedCollection 
		with: self templateComponent
		with: self templateComponent
		with: self templateComponent
]
