"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore
"
Class {
	#name : 'SSWDBKeyedStaticCollectionSpec',
	#superclass : 'SSWDBStaticCollectionSpec',
	#instVars : [
		'indexField',
		'updateTargetStatement'
	],
	#category : 'SSW ReStore Collections',
	#package : 'SSW ReStore Collections'
}

{ #category : 'change detection' }
SSWDBKeyedStaticCollectionSpec >> allAdditionsTo: aCollection [

	"Return an collection of SSWDBCollectionAdditions representing the addition of all aCollection's elements to itself, starting when empty"

	| additions |

	additions := OrderedCollection new: aCollection size.

	aCollection keysAndValuesDo: [ :key :each | additions add: (SSWDBCollectionAddition added: each at: key)].

	^additions
]

{ #category : 'change detection' }
SSWDBKeyedStaticCollectionSpec >> changesTo: aCollection from: aCollectionOfEntries [

	"Return the changes made to aCollection compared to aCollectionOf(Collection)Entries"

	| changes map |

	changes := OrderedCollection new: (aCollection size // 10).

	"Make a map of each index (as was) to its entry"
	self shouldCompareKeysByEquality
		ifTrue: [map := Dictionary new: aCollectionOfEntries size]
		ifFalse: [map := IdentityDictionary new: aCollectionOfEntries size].
	aCollectionOfEntries do: [ :each | map at: each index put: each].

	"Locate and remove entry for each member of the receiver and check for key change"
	aCollection keysAndValuesDo:
		[ :key :value || entry |
		entry := map removeKey: key ifAbsent: [NilCookie].
		entry == NilCookie
		ifTrue:
			["No entry found = element has been added to the receiver" 
			(changes add: (SSWDBCollectionAddition added: value at: key)) affectedEntry]
		ifFalse: 
			[(entry target == value or: [self shouldCompareChangesByEquality and: [entry target = value]]) ifFalse: [changes add: (SSWDBCollectionUpdate entry: entry newTarget: value)]]].

	"Any remaining entries indicate elements removed from the receiver"
	map do: [ :entry | changes add: (self elementRemovalClass newWithEntry: entry)].

	^changes
]

{ #category : 'change detection' }
SSWDBKeyedStaticCollectionSpec >> elementRemovalClass [

	"Return the class of change object representing the removal of an element for the type of collection modelled by the receiver"

	^SSWDBCollectionRemoval
]

{ #category : 'constants' }
SSWDBKeyedStaticCollectionSpec >> entryClass [

	"Return the class of collection entry appropriate for the receiver"
	
	^SSWDBKeyedCollectionEntry
]

{ #category : 'initialize/release' }
SSWDBKeyedStaticCollectionSpec >> freePreparedStatements [

	updateTargetStatement notNil ifTrue: 
		[updateTargetStatement free.
		updateTargetStatement := nil].

	super freePreparedStatements
]

{ #category : 'accessing' }
SSWDBKeyedStaticCollectionSpec >> indexField [

	"indexField stores the SSWDBField in the receiver's collectionTable
	that holds the index of the elements"
	
	indexField == nil ifTrue: [indexField := self collectionTable fieldAccessing: #index].
	
	^indexField
]

{ #category : 'accessing' }
SSWDBKeyedStaticCollectionSpec >> indexField: anSSWDBField [

	"indexField stores the SSWDBField in the receiver's collectionTable
	that holds the index of the elements"
	
	indexField := anSSWDBField
]

{ #category : 'change detection' }
SSWDBKeyedStaticCollectionSpec >> shouldCompareKeysByEquality [

	^false
]

{ #category : 'actions - api' }
SSWDBKeyedStaticCollectionSpec >> updateEntry: anSSWDBCollectionEntry withTarget: aProxy in: anSSWReStore [ 

	| query |

	query := SSWSQLUpdateObjectQuery 
			forObject: anSSWDBCollectionEntry
			withUpdates: 
				(SSWSQLFieldAssignmentCollection with:
					(SSWSQLFieldAssignment 
						field: self targetField
						value: aProxy)).

	(updateTargetStatement ifNil: [updateTargetStatement := anSSWReStore prepareStatementForQuery: query])
		values: query values;
		exec
]
