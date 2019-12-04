Extension { #name : #SortedCollection }

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> _changesFrom: aCollectionOfEntries [

	"Return the changes made to the receiver compared to aCollectionOf(Collection)Entries.
	For a SortedCollection, can ignore index changes"

	| changes map |

	changes := OrderedCollection new: (self size // 10).
	map := IdentityDictionary new: aCollectionOfEntries size.

	"Make a map of each element (as was) to its entry(s)"
	aCollectionOfEntries do: 
		[ :each | (map at: each target ifAbsentPut: [OrderedCollection new: 1]) addLast: each].

	"Locate and remove entry for each member of the receiver"
	self keysAndValuesDo:
		[ :newIndex :each |
		(map at: each ifAbsent: [(OrderedCollection new)]) removeFirstIfAbsent:
			"No entry found = element has been added to the receiver" 
			[changes add: (SSWDBCollectionAddition added: each)]].

	"Any remaining entries indicate elements removed from the receiver"
	map keysAndValuesDo:
		[ :each :entries | 
		entries isEmpty ifFalse:		"Minor optimisation"
			[entries do: [ :entry | changes add: (SSWDBCollectionRemoval newWithEntry: entry)]]].

	^changes
]

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> _collectionAdditions [

	"Defer to _nonKeyedCollectionAdditions, since indexing does not need to be stored 
	(it is defined by the sorting criteria)"

	^self _nonKeyedCollectionAdditions
]

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> _dbAdd: anObject [

	"For use when instantiating a collection from the database.
	Sorting is done by the recovery query, so we need to use an unconditional addLast: to avoice the expense of sorting, and potentially interrogating a non-recovered persistent object"

	^super addLast: anObject
]

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> directAdd: anObject [

	"For speed, ReStore will instruct the database to recover objects already sorted.
	directAdd: allows these sorted objects to be added to the receiver without further sorting"

	^super addLast: anObject
]

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> isSortedCollection [

	^true

]

{ #category : #'*SSW ReStore Collections' }
SortedCollection >> orderingSpecsFor: aClass in: aReStore [

	"Convert the receiver's sortBlock into DBOrderingSpecs"

	^(self sortBlock = SortedCollection new sortBlock and: [aClass isPersistentBaseClass]) "default ascending sort"
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
SortedCollection >> staticCollectionSpecClass [ 

	^SSWDBSortedStaticCollectionSpec


]
