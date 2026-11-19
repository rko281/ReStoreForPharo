Extension { #name : 'Object' }

{ #category : '*SSW ReStore Write Barrier' }
Object >> dbImmutabilityHandler [

	^self propertyAt: #dbImmutabilityHandler ifAbsent: [nil]
]

{ #category : '*SSW ReStore Write Barrier' }
Object >> dbImmutabilityHandler: anObject [

	self propertyAt: #dbImmutabilityHandler put: anObject
]

{ #category : '*SSW ReStore Write Barrier' }
Object >> isDBImmutable: aBoolean [

	self isImmutable: aBoolean
]

{ #category : '*SSW ReStore Write Barrier' }
Object >> isDBImmutable: aBoolean proxy: aDBProxy [

	self isDBImmutable: aBoolean.

	(aDBProxy _reStore tableForClass: self class) ifNotNil: 
		[ :table || nestedObjects |
		nestedObjects := IdentitySet new.
		table dataFields do: 
			[ :each | 
			each accessor isInlined 
				ifTrue: [nestedObjects add: (each accessor shallowValueIn: self)]
				ifFalse: [(each targetClass isPersistentBaseClass not and: [each targetClass isDirectlyPersisted]) ifTrue: [nestedObjects add: (each accessor valueIn: self)]]].
		nestedObjects do:
			[ :inlinedObj | 
			inlinedObj ifNotNil: 
				[ inlinedObj
					isDBImmutable: aBoolean proxy: aDBProxy;
					dbImmutabilityHandler: self]]]
]

{ #category : '*SSW ReStore Write Barrier' }
Object >> makeMutableAndAddToTransaction [

	self isImmutable ifTrue: 
		[(self _dbProxyIfNone: [nil]) 
		ifNil: 
			[self dbImmutabilityHandler ifNotNil: [ :handler | handler makeMutableAndAddToTransaction].
			self isDBImmutable: false]
		ifNotNil: 
			[ :proxy | 
			proxy _reStore transactionCritical: 
				[self isImmutable ifTrue: 
					[self isDBImmutable: false.
					proxy _reStore markProxyDirty: proxy]]]]
]

{ #category : '*SSW ReStore Write Barrier' }
Object >> modificationForbiddenFor: selector index: index value: value [

	self makeMutableAndAddToTransaction.
	^self perform: selector withArguments: { index. value }
]
