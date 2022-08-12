"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : #SSWDBKeyedStaticCollectionSpec,
	#superclass : #SSWDBStaticCollectionSpec,
	#instVars : [
		'indexField',
		'updateIndexStatement'
	],
	#category : #'SSW ReStore Collections'
}

{ #category : #'change detection' }
SSWDBKeyedStaticCollectionSpec >> allAdditionsTo: aCollection [

	"Return an collection of SSWDBCollectionAdditions representing the addition of all aCollection's elements to itself, starting when empty"

	| additions |

	additions := OrderedCollection new: aCollection size.

	aCollection keysAndValuesDo: [ :key :each | additions add: (SSWDBCollectionAddition added: each at: key)].

	^additions
]

{ #category : #'change detection' }
SSWDBKeyedStaticCollectionSpec >> changesTo: aCollection from: aCollectionOfEntries comparisonMap: aDictionary [

	"Private - Return the changes made to aCollection compared to aCollectionOf(Collection)Entries.
	For keyed changes, must consider additions, removals and changes of key"

	| changes |

	changes := OrderedCollection new: (aCollection size // 10).

	"Make a map of each element (as was) to its entry(s)"
	aCollectionOfEntries do: [ :each | (aDictionary at: (each target ifNil: [NilCookie]) ifAbsentPut: [OrderedCollection new: 1]) addLast: each].

	"Locate and remove entry for each member of the receiver and check for key change"
	aCollection keysAndValuesDo:
		[ :newKey :each || entry |
		entry := (aDictionary at: (each ifNil: [NilCookie]) ifAbsent: [OrderedCollection new]) removeFirstIfAbsent:
			"No entry found = element has been added to the receiver" 
			[(changes add: (SSWDBCollectionAddition added: each at: newKey)) affectedEntry].
		(entry index == newKey or: [self shouldCompareKeysByEquality and: [entry index = newKey]]) ifFalse: 
			[changes add: (self keyUpdateClass entry: entry newIndex: newKey)]].

	"Any remaining entries indicate elements removed from the receiver"
	aDictionary do:
		[ :entries | 
		entries isEmpty ifFalse:		"Minor optimisation"
			[entries do: [ :entry | changes add: (self elementRemovalClass newWithEntry: entry)]]].

	^changes
]

{ #category : #'change detection' }
SSWDBKeyedStaticCollectionSpec >> elementRemovalClass [

	"Return the class of change object representing the removal of an element for the type of collection modelled by the receiver"

	^SSWDBCollectionRemoval
]

{ #category : #constants }
SSWDBKeyedStaticCollectionSpec >> entryClass [

	"Return the class of collection entry appropriate for the receiver"
	
	^SSWDBKeyedCollectionEntry
]

{ #category : #'change detection' }
SSWDBKeyedStaticCollectionSpec >> equalityChangesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries, comparing via equality (=)"

	^self changesTo: aCollection from: aCollectionOfEntries comparisonMap: (Dictionary new: aCollectionOfEntries size)
]

{ #category : #'initialize/release' }
SSWDBKeyedStaticCollectionSpec >> freePreparedStatements [

	updateIndexStatement notNil ifTrue: 
		[updateIndexStatement free.
		updateIndexStatement := nil].

	super freePreparedStatements
]

{ #category : #'change detection' }
SSWDBKeyedStaticCollectionSpec >> identityChangesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries, comparing via identity (==)"

	^self changesTo: aCollection from: aCollectionOfEntries comparisonMap: (IdentityDictionary new: aCollectionOfEntries size)
]

{ #category : #accessing }
SSWDBKeyedStaticCollectionSpec >> indexField [

	"indexField stores the SSWDBField in the receiver's collectionTable
	that holds the index of the elements"
	
	indexField == nil ifTrue: [indexField := self collectionTable fieldAccessing: #index].
	
	^indexField
]

{ #category : #accessing }
SSWDBKeyedStaticCollectionSpec >> indexField: anSSWDBField [

	"indexField stores the SSWDBField in the receiver's collectionTable
	that holds the index of the elements"
	
	indexField := anSSWDBField
]

{ #category : #'change detection' }
SSWDBKeyedStaticCollectionSpec >> keyUpdateClass [

	"Return the class of change object representing a key update for the type of collection modelled by the receiver"

	^SSWDBCollectionIndexUpdate
]

{ #category : #'change detection' }
SSWDBKeyedStaticCollectionSpec >> shouldCompareKeysByEquality [

	^false
]

{ #category : #'actions - api' }
SSWDBKeyedStaticCollectionSpec >> updateEntry: anSSWDBCollectionEntry withIndex: anInteger in: anSSWReStore [ 

	| query |

	query := SSWSQLUpdateObjectQuery 
			forObject: anSSWDBCollectionEntry
			withUpdates: 
				(SSWSQLFieldAssignmentCollection with:
					(SSWSQLFieldAssignment 
						field: self indexField
						value: anInteger)).

	(updateIndexStatement ifNil: [updateIndexStatement := anSSWReStore prepareStatementForQuery: query])
		values: query values;
		exec
]
