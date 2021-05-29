Class {
	#name : #SSWReStoreDeleteDependentOwnedCollectionTest,
	#superclass : #SSWReStoreDeleteDependentCollectionTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreDeleteDependentOwnedCollectionTest class >> testSelectors [

	^self myTestSelectors
]

{ #category : #constants }
SSWReStoreDeleteDependentOwnedCollectionTest >> deleteQueriesCount [

	^1
]

{ #category : #constants }
SSWReStoreDeleteDependentOwnedCollectionTest >> ordersCollectionDefinition [

	"Owned collection"

	^(OrderedCollection of: SimpleProductOrder dependent owner: #customer)
]
