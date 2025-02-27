Extension { #name : 'Number' }

{ #category : '*SSW ReStore Querying' }
Number >> convertValue: aValue [

	"Field behaviour; needed when the result of a function is a fixed value.
	Depending on the function, database and driver combination we may sometimes get back the incorrect class of result.
	Attempt to coerce aValue if this is the case"

	aValue isNumber ifTrue: [^aValue].
	aValue isString ifTrue: [^self class readFrom: aValue readStream].
	aValue class = ByteArray ifTrue: [^self class readFrom: (AnsiString fromByteArray: aValue) readStream].

	self error: 'unsupported coercion'
]
