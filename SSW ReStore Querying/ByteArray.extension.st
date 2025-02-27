Extension { #name : 'ByteArray' }

{ #category : '*SSW ReStore Querying' }
ByteArray >> convertValue: aValue [

	"Field behaviour; needed when the result of a function is a fixed value.
	Depending on the function, database and driver combination we may sometimes get back the incorrect class of result.
	Attempt to coerce aValue if this is the case"

	aValue class = ByteArray ifTrue: [^aValue].
	aValue isString ifTrue: [^aValue asByteArray].
	aValue isNumber ifTrue: [^aValue displayString asByteArray].

	self error: 'unsupported coercion'
]
