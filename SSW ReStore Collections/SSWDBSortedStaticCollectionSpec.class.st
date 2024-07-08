"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBSortedStaticCollectionSpec',
	#superclass : 'SSWDBStaticCollectionSpec',
	#instVars : [
		'orderingSpecs'
	],
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'change detection' }
SSWDBSortedStaticCollectionSpec >> changesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries"

	| changes map |

	changes := OrderedCollection new: (aCollection size // 10).

	"Make a map of each element (as was) to its entry(s)"
	self shouldCompareChangesByEquality
		ifTrue: [map := Dictionary new: aCollectionOfEntries size]
		ifFalse: [map := IdentityDictionary new: aCollectionOfEntries size].

	aCollectionOfEntries do: [ :each | (map at: (each target ifNil: [NilCookie]) ifAbsentPut: [OrderedCollection new: 1]) addLast: each].

	"Locate and remove entry for each member of the receiver"
	aCollection do:
		[ :each |
		(map at: (each ifNil: [NilCookie]) ifAbsent: [OrderedCollection new]) removeFirstIfAbsent:
			"No entry found = element has been added to the receiver" 
			[changes add: (SSWDBCollectionAddition added: each)]].

	"Any remaining entries indicate elements removed from the receiver"
	map do:
		[ :entries | 
		entries isEmpty ifFalse:		"Minor optimisation"
			[entries do: [ :entry | changes add: (SSWDBCollectionRemoval newWithEntry: entry)]]].

	^changes
]

{ #category : 'accessing:derived' }
SSWDBSortedStaticCollectionSpec >> dbInstancesFor: aCollectionProxy [

	"Add the ordering"

	| instances |

	instances := super dbInstancesFor: aCollectionProxy.
	instances parser orderingSpecs: self orderingSpecs.

	^instances
]

{ #category : 'accessing' }
SSWDBSortedStaticCollectionSpec >> orderingSpecs [

	"Derived from the sortBlock of the templateCollection"

	orderingSpecs isNil ifTrue: [self setOrderingSpecs].

	^orderingSpecs
]

{ #category : 'accessing' }
SSWDBSortedStaticCollectionSpec >> orderingSpecs: anOrderedCollection [

	"Derived from the sortBlock of the templateCollection"

	orderingSpecs := anOrderedCollection
]

{ #category : 'constants' }
SSWDBSortedStaticCollectionSpec >> queryClass [

	"Return the class of select query appropriate for the receiver"
	
	^SSWSQLOrderedSelectQuery
]

{ #category : 'actions - api' }
SSWDBSortedStaticCollectionSpec >> refreshCollectionForProxy: aCollectionProxy [

	"We need to join to the target table in order to order the query (ie. sort the results correctly), therefore we may as well do a full recover"

	^self recoverCollectionForProxy: aCollectionProxy
]

{ #category : 'accessing:derived' }
SSWDBSortedStaticCollectionSpec >> selectQueryIn: anSSWReStore [

	| query |

	query := super selectQueryIn: anSSWReStore.

	self targetClass isDirectlyPersisted
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

{ #category : 'accessing' }
SSWDBSortedStaticCollectionSpec >> setOrderingSpecs [

	self orderingSpecs: (self templateCollection orderingSpecsFor: self targetClass in: self reStore)
]
