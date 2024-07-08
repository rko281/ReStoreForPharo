Extension { #name : 'ScaledDecimal' }

{ #category : '*SSW ReStore Base Additions' }
ScaledDecimal class >> withPrecision: precisionInteger scale: scaleInteger [ 

	"Return an instance of an SSWDBScaledDecimalWithInfo which can represent this"

	^(self withScale: scaleInteger)
		precision: precisionInteger;
		yourself
]

{ #category : '*SSW ReStore Base Additions' }
ScaledDecimal class >> withScale: scaleInteger [

	"Return an instance of an SSWDBScaledDecimalWithInfo which can represent this"

	^SSWDBScaledDecimalWithInfo new
		scale: scaleInteger;
		yourself
]
