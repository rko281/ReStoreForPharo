"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWReStoreOwnedCollectionReadWithComponentsTest',
	#superclass : 'SSWReStoreReadWithComponentsTest',
	#category : 'SSW ReStore Tests',
	#package : 'SSW ReStore Tests'
}

{ #category : 'public' }
SSWReStoreOwnedCollectionReadWithComponentsTest class >> testSelectors [

	^self myTestSelectors
]

{ #category : 'constants' }
SSWReStoreOwnedCollectionReadWithComponentsTest >> ordersCollectionDefinition [

	"Owned collection"

	^(OrderedCollection of: SimpleProductOrder related owner: #customer)
]
