Extension { #name : 'Dictionary' }

{ #category : '*SSW ReStore for Pharo' }
Dictionary >> _superValuesRemovedBy: aCollectionOfChanges [

	"Pass-thru to default implementation of _valuesRemovedBy: for benefit of non-Set subclasses
	(Dictionary is a subclass of Set in Dolphin)"

	^super _valuesRemovedBy: aCollectionOfChanges

]

{ #category : '*SSW ReStore for Pharo' }
Dictionary >> atNewIndex: index put: anAssociation [

	self isImmutable ifTrue: 
		[ self setAssociation: anAssociation isDBImmutable: true].

	^super atNewIndex: index put: anAssociation
]

{ #category : '*SSW ReStore for Pharo' }
Dictionary >> postCopy [
	"Must copy the associations, or later store will affect both the
original and the copy"

	array := array collect: [ :association |
		association ifNotNil: [ association copy ] ].
	self setArrayImmutability 
]

{ #category : '*SSW ReStore for Pharo' }
Dictionary >> rehash [
	"Smalltalk rehash."
	| newSelf |
	newSelf := self species new: self size.
	self associationsDo: [:each | newSelf noCheckAdd: each].
	array := newSelf array.
	self setArrayImmutability 
]
