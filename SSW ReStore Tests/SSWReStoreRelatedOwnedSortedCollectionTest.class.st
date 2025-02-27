"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreRelatedOwnedSortedCollectionTest',
	#superclass : 'SSWReStoreRelatedOwnedOrderedCollectionTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'accessing' }
SSWReStoreRelatedOwnedSortedCollectionTest >> componentDefinition [

	^SortedCollection of: GenericOwnedTest related owner: #owner
]

{ #category : 'public' }
SSWReStoreRelatedOwnedSortedCollectionTest >> replaceInCollection: aCollection [

	^(aCollection remove: aCollection last) -> (aCollection add: self templateComponent)
]

{ #category : 'accessing' }
SSWReStoreRelatedOwnedSortedCollectionTest >> templateCollection [

	^SortedCollection 
		with: self templateComponent
		with: self templateComponent
		with: self templateComponent
]
