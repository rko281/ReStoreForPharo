Class {
	#name : 'SSWDBSortedOwnedCollectionSpec',
	#superclass : 'SSWDBOwnedCollectionSpec',
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'testing' }
SSWDBSortedOwnedCollectionSpec >> hasCollection: updatedCollection anyAdditionsOrRemovalsFrom: originalCollection [

	updatedCollection size = originalCollection size ifFalse: [^true].

	1 to: originalCollection size do: [ :index | (originalCollection at: index) == (updatedCollection at: index) ifFalse: [^true]].

	^false
]

{ #category : 'accessing' }
SSWDBSortedOwnedCollectionSpec >> queryClass [

	"Return the correct query class to use for the receiver"
	
	^SSWSQLOrderedSelectQuery
]

{ #category : 'initializing' }
SSWDBSortedOwnedCollectionSpec >> setOrderingSpecs [

	self orderingSpecs: (self templateCollection orderingSpecsFor: self targetClass in: self reStore)
]
