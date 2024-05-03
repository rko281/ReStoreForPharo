"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWReStoreOwnedCollectionSubQueryTest,
	#superclass : #SSWReStoreCollectionSubQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreOwnedCollectionSubQueryTest class >> testSelectors [

	^self myTestSelectors
]

{ #category : #constants }
SSWReStoreOwnedCollectionSubQueryTest >> ordersCollectionDefinition [

	"Owned collection"

	^(OrderedCollection of: SimpleProductOrder related owner: #customer)
]
