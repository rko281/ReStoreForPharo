Extension { #name : #Set }

{ #category : #'*SSW ReStore Collections' }
Set >> _changesFrom: aSetOfEntries [

	"Return the changes made to the receiver compared to aSetOf(Collection)Entries.
	For a Set, consider additions and removals only"

	| changes oldSet |

	changes := OrderedCollection new.
	oldSet := aSetOfEntries collect: [ :entry | entry target].

	self do: [ :each | (oldSet identityIncludes: each) ifFalse: 
						[changes add: (SSWDBCollectionAddition added: each)]].

	aSetOfEntries do: [ :entry | (self identityIncludes: entry target) ifFalse: 
						[changes add: (SSWDBCollectionRemoval newWithEntry: entry)]].

	^changes
]

{ #category : #'*SSW ReStore Collections' }
Set >> _superValuesRemovedBy: aCollectionOfChanges [

	"Pass-thru to default implementation of _valuesRemovedBy: for benefit of non-Set subclasses"

	^super _valuesRemovedBy: aCollectionOfChanges

]

{ #category : #'*SSW ReStore Collections' }
Set >> _valuesRemovedBy: aCollectionOfChanges [

	"Overriden to take advantage of the lack of duplicates in the receiver:
	if a change removes an element from the receiver, then all occurrences of that element are removed"

	^aCollectionOfChanges collect: [ :each | each affectedEntry target]
]
