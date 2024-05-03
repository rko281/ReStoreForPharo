Extension { #name : 'Date' }

{ #category : '*SSW ReStore for Pharo' }
Date class >> readFrom: aStream format: formatString [

	| datePart |
	
	datePart := aStream upTo: $T.
	aStream atEnd ifFalse: [ aStream position: aStream position - 1 ].

	^self readFrom: datePart readStream pattern: formatString asLowercase
]
