Extension { #name : 'OrderedCollection' }

{ #category : '*SSW ReStore Write Barrier' }
OrderedCollection >> isDBImmutable: aBoolean [

	super isDBImmutable: aBoolean.
	array 
		isImmutable: aBoolean;
		dbImmutabilityHandler: self
]
