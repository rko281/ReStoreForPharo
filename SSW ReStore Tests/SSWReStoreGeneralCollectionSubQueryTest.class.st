"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWReStoreGeneralCollectionSubQueryTest,
	#superclass : #SSWReStoreCollectionSubQueryTest,
	#category : #'SSW ReStore Tests'
}

{ #category : #public }
SSWReStoreGeneralCollectionSubQueryTest class >> testSelectors [

	^self myTestSelectors
]

{ #category : #constants }
SSWReStoreGeneralCollectionSubQueryTest >> ordersCollectionDefinition [

	"Non-owned collection"

	^(OrderedCollection of: SimpleProductOrder related dependent)
]
