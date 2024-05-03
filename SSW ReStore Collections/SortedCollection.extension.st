Extension { #name : #SortedCollection }

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> _dbAdd: anObject [

	"For use when instantiating a collection from the database.
	Sorting is done by the recovery query, so we need to use an unconditional addLast: to avoice the expense of sorting, and potentially interrogating a non-recovered persistent object"

	^super addLast: anObject
]

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> orderingSpecsFor: aClass in: aReStore [

	"Convert the receiver's sortBlock into DBOrderingSpecs"

	^(self sortBlock = SortedCollection new sortBlock and: [aClass isDirectlyPersisted]) "default ascending sort"
	ifTrue:
		[OrderedCollection with: (SSWDBOrderingSpec ascending: #target)]
	ifFalse:
		[| instances |
		instances := aReStore instancesOf: aClass.
		instances sortBlock: (self sortBlock ifNil: [SortedCollection defaultSortBlock]).
		instances parser orderingSpecs collect: 
			[ :each || field |
			field := each criteria.
			field isNil 
				ifTrue: [each criteria: #target]
				ifFalse: [each criteria: field accessor name]]]
]

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> ownedCollectionSpecClass [ 

	"Return the class of owned collection spec that is appropriate for this kind of collection"

	^SSWDBSortedOwnedCollectionSpec
]

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> staticCollectionSpecClass [ 

	^SSWDBSortedStaticCollectionSpec


]
