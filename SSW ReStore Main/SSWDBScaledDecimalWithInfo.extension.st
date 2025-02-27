Extension { #name : 'SSWDBScaledDecimalWithInfo' }

{ #category : '*SSW ReStore Main' }
SSWDBScaledDecimalWithInfo >> instanceFromDBValue: aValue in: aReStore [

	"Handle SQL dialects which do not explicity support decimals"

	| scaleFactor |

	(aValue isNil or: [aValue isKindOf: ScaledDecimal]) ifTrue: [^aValue].

	"Convert to a ScaledDecimal, rounding to the scale of the receiver"
	scaleFactor := 10 ** self scale.

	^(ScaledDecimal newFromNumber: (aValue * scaleFactor) rounded scale: self scale) / scaleFactor
]
