"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBSortedStaticCollectionSpec,
	#superclass : #SSWDBStaticCollectionSpec,
	#instVars : [
		'orderingSpecs'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #'accessing:derived' }
SSWDBSortedStaticCollectionSpec >> dbInstancesFor: aCollectionProxy [

	"Add the ordering"

	| instances |

	instances := super dbInstancesFor: aCollectionProxy.
	instances parser orderingSpecs: self orderingSpecs.

	^instances
]

{ #category : #accessing }
SSWDBSortedStaticCollectionSpec >> orderingSpecs [

	"Derived from the sortBlock of the templateCollection"

	orderingSpecs isNil ifTrue: [self setOrderingSpecs].

	^orderingSpecs
]

{ #category : #accessing }
SSWDBSortedStaticCollectionSpec >> orderingSpecs: anOrderedCollection [

	"Derived from the sortBlock of the templateCollection"

	orderingSpecs := anOrderedCollection
]

{ #category : #constants }
SSWDBSortedStaticCollectionSpec >> queryClass [

	"Return the class of select query appropriate for the receiver"
	
	^SSWSQLOrderedSelectQuery
]

{ #category : #'actions - api' }
SSWDBSortedStaticCollectionSpec >> refreshCollectionForProxy: aCollectionProxy [

	"We need to join to the target table in order to order the query (ie. sort the results correctly), therefore we may as well do a full recover"

	^self recoverCollectionForProxy: aCollectionProxy
]

{ #category : #'accessing:derived' }
SSWDBSortedStaticCollectionSpec >> selectQueryIn: anSSWReStore [

	| query |

	query := super selectQueryIn: anSSWReStore.

	self targetClass isPersistentBaseClass
	ifTrue:
		[(self orderingSpecs isEmpty or: [self orderingSpecs first isAscending])
			ifTrue: [query orderAscendingBy: self targetField]
			ifFalse: [query orderDescendingBy: self targetField]]
	ifFalse:
		[| targetTable |
		targetTable := anSSWReStore tableForClass: self targetClass.
		self orderingSpecs do: 
			[ :spec | 
			spec isAscending
				ifTrue: [query orderAscendingBy: (targetTable fieldAccessing: spec criteria)]
				ifFalse: [query orderDescendingBy: (targetTable fieldAccessing: spec criteria)]]].

	^query
]

{ #category : #accessing }
SSWDBSortedStaticCollectionSpec >> setOrderingSpecs [

	self orderingSpecs: (self templateCollection orderingSpecsFor: self targetClass in: self reStore)
]
