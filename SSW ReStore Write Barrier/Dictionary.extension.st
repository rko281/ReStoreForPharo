Extension { #name : 'Dictionary' }

{ #category : '*SSW ReStore Write Barrier' }
Dictionary >> isDBImmutable: aBoolean [

	super isDBImmutable: aBoolean.
	self associationsDo: [ :each | self setAssociation: each isDBImmutable: aBoolean ]
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
