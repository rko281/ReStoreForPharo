Extension { #name : 'OrderedCollection' }

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> isDBImmutable: aBoolean [

	super isDBImmutable: aBoolean.
	array 
		isImmutable: aBoolean;
		dbImmutabilityHandler: self
]

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> setArrayImmutability [

	self isImmutable ifTrue: 
		[ array 
			isImmutable: true;
			dbImmutabilityHandler: self ]
]
