Extension { #name : 'Set' }

{ #category : '*SSW ReStore for Pharo' }
Set >> grow [
	"Grow the elements array and reinsert the old elements"

	| oldElements |
	oldElements := array.
	array := Array new: (HashTableSizes atLeast: oldElements size * 2).
	tally := 0.
	oldElements do: [ :element | element ifNotNil: [ self noCheckAdd: element enclosedElement ] ].
	self setArrayImmutability 
]

{ #category : '*SSW ReStore for Pharo' }
Set >> postCopy [
	super postCopy.
	array := array copy.
	self setArrayImmutability 
]

{ #category : '*SSW ReStore for Pharo' }
Set >> rehash [
	| newSelf |
	newSelf := self species new: self size.
	self do: [:each | newSelf noCheckAdd: each].
	array := newSelf array.
	self setArrayImmutability 
]

{ #category : '*SSW ReStore for Pharo' }
Set >> withArray: anArray [
	"private -- for use only in copy"
	"I want to get a conflict"
	array := anArray.
	self setArrayImmutability 
]
