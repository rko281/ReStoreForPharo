Extension { #name : 'HashedCollection' }

{ #category : '*SSW ReStore Write Barrier' }
HashedCollection >> isDBImmutable: aBoolean [

	super isDBImmutable: aBoolean.
	array 
		isImmutable: aBoolean;
		dbImmutabilityHandler: self
]
