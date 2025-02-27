Extension { #name : 'Object' }

{ #category : '*SSW ReStore Querying' }
Object >> concatenatedWith: aConcatenatedCollection [

	^aConcatenatedCollection 
		addLast: self; 
		yourself
]

{ #category : '*SSW ReStore Querying' }
Object >> forConcatenation [

	^self
]

{ #category : '*SSW ReStore Querying' }
Object >> imageDo: imageBlock databaseDo: databaseBlock [

	"Allow different code to be 'evaluated' depending on whether execution is in-image or 'in' the database (in the latter case code is not actually executed but converted to SQL)"

	^imageBlock value
]

{ #category : '*SSW ReStore Querying' }
Object >> isRequiredForSimilarity [

	"Private - Is this object required to be similar when testing similarity of its owner?"
	^true
]

{ #category : '*SSW ReStore Querying' }
Object >> isSimilarTo: anObject [

	^self perform: anObject similarityComparator with: anObject
]

{ #category : '*SSW ReStore Querying' }
Object >> qualify: instances in: aReStore via: aCollection [

	(aReStore tableForClass: self class) allDataFieldsDo:
		[ :field || value |
		value := field accessor valueIn: self.
		value isRequiredForSimilarity ifTrue:
			[| accessor chain |
			accessor := field accessor.
			chain := aCollection copyWith: accessor name.
			[accessor isInlined] whileTrue: 
				[accessor := accessor inlinedAccessor.
				chain := chain copyWith: accessor name].
			(field targetClass isPersistentIn: aReStore)
			ifTrue: 
				[(value _dbProxyIfNone: [nil])
					ifNil: [value qualify: instances in: aReStore via: chain]
					ifNotNil: [ :proxy | instances qualifyWith: [ :each | (each chainPerform: chain) _id = proxy _id]]]
			ifFalse: 
				[instances qualifyWith: [ :each | (each chainPerform: chain) isSimilarTo: value]]]]
]

{ #category : '*SSW ReStore Querying' }
Object >> similarityComparator [

	"Private - Default is equality"

	^#=
]

{ #category : '*SSW ReStore Querying' }
Object >> || anObject [

	"Concatenate the receiver with anObject, returning the resulting collection"

	^anObject concatenatedWith: (ConcatenatedCollection with: self)
]
