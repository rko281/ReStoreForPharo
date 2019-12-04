"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreOwnedCollectionReadWithComponentsTest,
	#superclass : #SSWReStoreReadWithComponentsTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreOwnedCollectionReadWithComponentsTest class >> testSelectors [

	^self myTestSelectors
]

{ #category : #constants }
SSWReStoreOwnedCollectionReadWithComponentsTest >> ordersCollectionDefinition [

	"Owned collection"

	^(OrderedCollection of: SimpleProductOrder related owner: #customer)
]
