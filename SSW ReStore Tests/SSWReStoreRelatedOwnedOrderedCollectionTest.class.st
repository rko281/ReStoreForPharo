"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreRelatedOwnedOrderedCollectionTest,
	#superclass : #SSWReStoreGenericRelatedCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #accessing }
SSWReStoreRelatedOwnedOrderedCollectionTest >> componentDefinition [

	^OrderedCollection of: GenericOwnedTest related owner: #owner
]

{ #category : #public }
SSWReStoreRelatedOwnedOrderedCollectionTest >> replaceInCollection: aCollection [

	^(aCollection at: aCollection size) -> (aCollection at: aCollection size put: self templateComponent)
]

{ #category : #accessing }
SSWReStoreRelatedOwnedOrderedCollectionTest >> templateCollection [

	^OrderedCollection 
		with: self templateComponent
		with: self templateComponent
		with: self templateComponent
]
