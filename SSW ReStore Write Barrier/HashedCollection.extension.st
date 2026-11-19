Extension { #name : 'HashedCollection' }

{ #category : '*SSW ReStore Write Barrier' }
HashedCollection >> isDBImmutable: aBoolean [

	super isDBImmutable: aBoolean.
	array 
		isImmutable: aBoolean;
		dbImmutabilityHandler: self
]

{ #category : '*SSW ReStore Write Barrier' }
HashedCollection >> setArrayImmutability [

	self isImmutable ifTrue: 
		[ array 
			isImmutable: true;
			dbImmutabilityHandler: self ]
]
