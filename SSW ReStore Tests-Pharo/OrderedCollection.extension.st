Extension { #name : 'OrderedCollection' }

{ #category : '*SSW ReStore Tests-Pharo' }
OrderedCollection >> become: anObject [

	self isImmutable ifFalse: [ ^super become: anObject ].
	self isImmutable: false.
	^[super become: anObject] ensure: [ self isImmutable: true ]
]
