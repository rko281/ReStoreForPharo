Extension { #name : 'String' }

{ #category : '*SSW ReStore Querying' }
String >> asWildcard [

	^WildcardString new
		string: self;
		yourself

]

{ #category : '*SSW ReStore Querying' }
String >> convertValue: aValue [

	"Field behaviour; needed when the result of a function is a fixed value.
	Depending on the function, database and driver combination we may sometimes get back the incorrect class of result.
	Attempt to coerce aValue if this is the case"

	aValue isString ifTrue: [^aValue upTo: Character null].
	aValue isNumber ifTrue: [^aValue displayString].
	aValue class = ByteArray ifTrue: [^AnsiString fromByteArray: aValue].

	self error: 'unsupported coercion'
]
