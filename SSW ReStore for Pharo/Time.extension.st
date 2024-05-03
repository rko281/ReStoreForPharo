Extension { #name : 'Time' }

{ #category : '*SSW ReStore for Pharo' }
Time >> _withResolution: anInteger [

	"Modify the receiver to have the given resolution (number of fractional digits) anInteger, i.e. 0 for seconds resolution, 3 for milliseconds etc."

	nanos := (nanos * (10 ** (anInteger - 9))) truncated * (10 ** (9 - anInteger))
]

{ #category : '*SSW ReStore for Pharo' }
Time >> withResolution: anInteger [

	"Return a copy of the receiver with the given resolution (number of fractional digits) anInteger, i.e. 0 for seconds resolution, 3 for milliseconds etc."

	^self copy _withResolution: anInteger
]
