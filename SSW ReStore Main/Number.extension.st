Extension { #name : #Number }

{ #category : #'*SSW ReStore Main' }
Number class >> instanceFromDBValue: aValue in: anSSWReStore [

	"ASSERT: aValue isNil OR aValue isKindOf: self"

	^aValue
]
