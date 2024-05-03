"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreGeneralCollectionReadWithComponentsTest,
	#superclass : #SSWReStoreReadWithComponentsTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreGeneralCollectionReadWithComponentsTest class >> testSelectors [

	^self myTestSelectors
]

{ #category : #constants }
SSWReStoreGeneralCollectionReadWithComponentsTest >> ordersCollectionDefinition [

	"General (non-owned) collection"

	^(OrderedCollection of: SimpleProductOrder related)
]
