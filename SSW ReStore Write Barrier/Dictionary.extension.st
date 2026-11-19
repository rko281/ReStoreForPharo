Extension { #name : 'Dictionary' }

{ #category : '*SSW ReStore Write Barrier' }
Dictionary >> atNewIndex: index put: anAssociation [

	self isImmutable ifTrue: 
		[ self setAssociation: anAssociation isDBImmutable: true].

	^super atNewIndex: index put: anAssociation
]

{ #category : '*SSW ReStore Write Barrier' }
Dictionary >> isDBImmutable: aBoolean [

	super isDBImmutable: aBoolean.
	self associationsDo: [ :each | self setAssociation: each isDBImmutable: aBoolean ]
]

{ #category : '*SSW ReStore Write Barrier' }
Dictionary >> postCopy [
	"Must copy the associations, or later store will affect both the
original and the copy"

	array := array collect: [ :association |
		association ifNotNil: [ association copy ] ].
	self setArrayImmutability 
]

{ #category : '*SSW ReStore Write Barrier' }
Dictionary >> rehash [
	"Smalltalk rehash."
	| newSelf |
	newSelf := self species new: self size.
	self associationsDo: [:each | newSelf noCheckAdd: each].
	array := newSelf array.
	self setArrayImmutability 
]

{ #category : '*SSW ReStore Write Barrier' }
Dictionary >> setAssociation: anAssociation isDBImmutable: aBoolean [

	anAssociation
		isDBImmutable: aBoolean;
		dbImmutabilityHandler: self.
	anAssociation value ifNotNil: 
		[ :value | 
		((value isKindOf: Collection) and: [(value isKindOf: String) not]) ifTrue: 
			[value 
				isImmutable: aBoolean;
				dbImmutabilityHandler: self]]
]
