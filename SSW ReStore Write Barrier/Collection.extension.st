Extension { #name : 'Collection' }

{ #category : '*SSW ReStore Write Barrier' }
Collection >> isDBImmutable: aBoolean proxy: aDBProxy [
	
	| cls |

	self isDBImmutable: aBoolean.

	(self isEmpty not and: [(cls := self anyOne class) isPersistentBaseClass not and: [cls isDirectlyPersisted]]) ifTrue:
		[self do:
			[ :objOrNil | 
			objOrNil ifNotNil: 
				[ :obj |
				obj 
					isDBImmutable: aBoolean;
					dbImmutabilityHandler: self]]]
]
